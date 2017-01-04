#!/bin/sh

echo "Assumes packages built from Adaptive Computing upstream!!!"

# Disable started services automatically (i.e., when booting via /sbin/init)
# They should be started manually
chkconfig trqauthd off
chkconfig pbs_server off
chkconfig pbs_sched off
chkconfig pbs_mom off
