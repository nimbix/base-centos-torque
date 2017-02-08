#!/bin/bash

# remove logs
rm -f /var/log/torque/*/*

MYHOST=`hostname`
MASTER=`head -1 /etc/JARVICE/nodes`
if [ "$MYHOST" = "JARVICE" ]; then
	echo "Cannot run from persistent environment; must be ephemeral."
	exit 1
fi

echo $MASTER | sudo tee /var/spool/torque/server_name
sudo rm /var/spool/torque/mom_priv/config
sudo touch /var/spool/torque/mom_priv/config
echo "\$pbsserver $MASTER" |tee /var/spool/torque/mom_priv/config

sudo service trqauthd start
sleep 1

if [ $MYHOST = $MASTER ]; then

	NP=`wc -l /etc/JARVICE/cores|awk '{print $1}'`
	NN=`wc -l /etc/JARVICE/nodes|awk '{print $1}'`
	let NP=$NP/$NN
	sudo rm -f /var/spool/torque/server_priv/nodes
	for i in `cat /etc/JARVICE/nodes`; do
		echo "$i np=$NP" >> /var/spool/torque/server_priv/nodes
	done
	service pbs_server start >>/tmp/torque-setup.log 2>&1
	service pbs_sched start >>/tmp/torque-setup.log 2>&1

        sleep 5
        
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
	qmgr -e -c "set server submit_hosts = `hostname`"
        qmgr -e -c "set server allow_node_submit = True"
        NNODES=`cat /etc/JARVICE/nodes | wc -l`
        let NSLAVES=${NNODES}-1
        for i in `tail -n ${NNODES} /etc/JARVICE/nodes`; do
            qmgr -e -c "set server submit_hosts += ${i}"
        done
        # Set a cron task to restart the weak torque scheduler process every 5 mins
	cat `dirname $0`/crontab | sudo tee -a /etc/crontab
	sudo /etc/init.d/crond restart
fi

# This must be running to start the services and modify the config
sudo service trqauthd restart
sleep 3

sudo service pbs_mom restart
sleep 3
