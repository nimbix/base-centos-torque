#!/bin/bash
#
# Copyright (c) 2016, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.
#
# Author: Stephen Fox (stephen.fox@nimbix.net)

################################################################################
# launch_all.sh - Launch TORQUE server and slaves if not already running
#
# This script should be called if you want to submit a job to torque via
#  qsub or qrun in the current job environment.
################################################################################

# Try to connect each second, up to 60 times before we give up..
#echo "ConnectionAttempts 60" ~/.ssh/config
toolsdir=/usr/lib/JARVICE/tools
[ -d /usr/local/JARVICE/tools ] && toolsdir=/usr/local/JARVICE/tools
$toolsdir/bin/python_ssh_test 60

for i in `cat /etc/JARVICE/nodes`; do
    echo "TORQUE - Launching node: $i"
    ssh -n -f $i "sudo /usr/local/scripts/torque/launch.sh"
done

sleep 5

# Block until all nodes are ready
NNODES=`cat /etc/JARVICE/nodes | wc -l`
while [ 1 ]; do
    READY=$(qnodes -a | grep "state =" | grep free | wc -l)
    if [ $? -gt 0 ] || [ ${READY} -lt ${NNODES} ]; then
        sleep 2
        echo "TORQUE - $READY of $NNODES nodes are ready..."
    else
        echo "TORQUE - All nodes ($NNODES) are ready..."
        break
    fi
done
