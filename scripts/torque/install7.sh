#!/bin/sh

echo "Assumes CentOS 7 TORQUE packages!!!"

grep -q /usr/local/scripts/torque/launch.sh /etc/rc.local || \
    echo "su -l -c 'sudo /usr/local/scripts/torque/launch.sh' nimbix" \
    >>/etc/rc.local
#chmod +x /etc/rc.d/rc.local

pbs_server -f -t create

echo "Launch TORQUE on all nodes: /usr/local/scripts/torque/launch_all.sh"
echo "OR"
echo "Launch TORQUE nodes individually: /usr/local/scripts/torque/launch.sh"

