#!/bin/sh

echo "Assumes packages built from Adaptive Computing upstream!!!"

# Disable started services automatically (i.e., when booting via /sbin/init)
# They should be started manually
chkconfig trqauthd off
chkconfig pbs_server off
chkconfig pbs_sched off
chkconfig pbs_mom off

grep -q /usr/local/scripts/torque/launch.sh /etc/rc.local || \
    echo "su -l -c 'sudo /usr/local/scripts/torque/launch.sh' nimbix" \
    >>/etc/rc.local

echo "Launch TORQUE on all nodes: /usr/local/scripts/torque/launch_all.sh"
echo "OR"
echo "Launch TORQUE nodes individually: /usr/local/scripts/torque/launch.sh"

