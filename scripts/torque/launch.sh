#!/bin/bash

svc()
{
    if [ -d /etc/systemd ]; then
        systemctl "$2" "$1"
    else
        service "$1" "$2"
    fi
}

if [ -d /var/spool/torque ]; then
    SPOOL=/var/spool/torque
else
    SPOOL=/var/lib/torque
fi

if [ "$(whoami)" != "root" ]; then
    echo "$0 must be executed with root privileges!"
    exit 1
fi

ACTION=start
[ "$1" = "restart" ] && ACTION=restart

# remove logs
rm -f /var/log/torque/*/*

DOMAIN=`domainname`
[ "$DOMAIN" = "(none)" ] && DOMAIN=localdomain
hostname | grep -q '\.' || hostname `hostname`.$DOMAIN
MYHOST=`hostname`
MASTER=`head -1 /etc/JARVICE/nodes`.$DOMAIN

if [ "$MYHOST" = "JARVICE.$DOMAIN" ]; then
    echo "Cannot run from persistent environment; must be ephemeral."
    exit 1
fi

# TORQUE complains when referenced host name isn't listed first
sed -r -i -e 's/(.+) (.+) (.+.localdomain)/\1 \3 \2/' /etc/hosts

if [ "$ACTION" = "start" ]; then
    test_service=pbs_mom
    [ "$MYHOST" = "$MASTER" ] && test_service=pbs_server
    svc status $test_service status 2>&1 >/dev/null && \
        echo "TORQUE already appears to be running on $MYHOST!" && \
        exit 1
fi

echo "$MASTER" | tee $SPOOL/server_name
echo "\$pbsserver $MASTER" | tee $SPOOL/mom_priv/config

if [ -d /etc/munge && ! -f /etc/munge/munge.key ]; then
    dd if=/home/nimbix/.ssh/id_rsa of=/etc/munge/munge.key bs=1024 count=1
    chown munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
    svc munge start
fi
svc trqauthd $ACTION
sleep 1

if [ "$MYHOST" = "$MASTER" ]; then

    NP=`wc -l /etc/JARVICE/cores|awk '{print $1}'`
    NN=`wc -l /etc/JARVICE/nodes|awk '{print $1}'`
    let NP=$NP/$NN
    rm -f $SPOOL/server_priv/nodes
    for i in `cat /etc/JARVICE/nodes`; do
        echo "$i.$DOMAIN np=$NP" >> $SPOOL/server_priv/nodes
    done

    svc pbs_sched $ACTION
    svc pbs_server $ACTION

    sleep 1

    qmgr -e -c "delete queue jarvice"
    qmgr -e -c "delete queue batch"
    qmgr -e -c "create queue jarvice queue_type=execution"
    qmgr -e -c "set queue jarvice resources_max.walltime = 10000:00:00"
    qmgr -e -c "set queue jarvice resources_default.nodes = 1"
    qmgr -e -c "set queue jarvice resources_default.walltime = 10000:00:00"
    qmgr -e -c "set queue jarvice enabled = True"
    qmgr -e -c "set queue jarvice started = True"
    qmgr -e -c "set server scheduling = True"
    qmgr -e -c "set server managers = nimbix@$MYHOST"
    qmgr -e -c "set server operators = nimbix@$MYHOST"
    qmgr -e -c "set server default_queue = jarvice"
    qmgr -e -c "set server log_events = 511"
    qmgr -e -c "set server scheduler_iteration = 1"
    qmgr -e -c "set server node_ping_rate = 30"
    qmgr -e -c "set server node_check_rate = 60"
    qmgr -e -c "set server tcp_timeout = 10"
    qmgr -e -c "set server mom_job_sync = True"
    qmgr -e -c "set server node_pack = True"
    qmgr -e -c "set server keep_completed = 300"
    qmgr -e -c "set server log_file_max_size = 1048576"
    qmgr -e -c "set server log_file_roll_depth = 1"
    qmgr -e -c "set server log_keep_days = 7"
    qmgr -e -c "set server next_job_number = 1"
    qmgr -e -c "set server submit_hosts = $MYHOST"
    qmgr -e -c "set server allow_node_submit = True"
    NNODES=`cat /etc/JARVICE/nodes | wc -l`
    let NSLAVES=${NNODES}-1
    for i in `tail -n ${NSLAVES} /etc/JARVICE/nodes`; do
        qmgr -e -c "set server managers += nimbix@${i}.$DOMAIN"
        qmgr -e -c "set server operators += nimbix@${i}.$DOMAIN"
        qmgr -e -c "set server submit_hosts += ${i}.$DOMAIN"
    done

    # Set a cron task to restart the weak torque scheduler process every 5 mins
    #grep -q torque/restart_sched.sh /etc/crontab || \
    #    cat `dirname $0`/crontab | tee -a /etc/crontab && \
    #    /etc/init.d/crond restart
fi

[ "$MYHOST" != "$MASTER" ] && sleep 3
svc pbs_mom $ACTION

