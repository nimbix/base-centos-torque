#!/bin/bash

torque_version=6.1.2
torque_user=nimbix
#EXP_DEBUG="-d"

set -x
set -e

yum install -y boost-devel \
    libxml2-devel \
    make openssl-devel \
    rpm-build \
    git \
    vixie-cron \
    openmpi-devel \
    expect

yum groupinstall -y 'Development Tools'
yum clean all

cd /tmp
git clone -b $torque_version https://github.com/adaptivecomputing/torque.git

cd /tmp/torque
./autogen.sh
./configure --prefix=/usr
# Building the rpm doesn't seem to work on CentOS 7
#make rpm
#cp -r /root/rpmbuild/RPMS/$(uname -m) /tmp/PKG
#rm -rf /root/rpmbuild/RPMS/$(uname -m)
#cd /tmp/PKG
#rpm -ivh *.rpm
#rm -rf *.rpm
make all
make install
/sbin/ldconfig


for i in contrib/systemd/*.service; do
    ./buildutils/install-sh -m 644 $i /usr/lib/systemd/system/$(basename $i)
done

cat <<-EOF >>/etc/services
# Standard PBS services
pbs           15001/tcp           # pbs server (pbs_server)
pbs           15001/udp           # pbs server (pbs_server)
pbs_mom       15002/tcp           # mom to/from server
pbs_mom       15002/udp           # mom to/from server
pbs_resmom    15003/tcp           # mom resource management requests
pbs_resmom    15003/udp           # mom resource management requests
pbs_sched     15004/tcp           # scheduler
pbs_sched     15004/udp           # scheduler
trqauthd      15005/tcp           # authorization daemon
trqauthd      15005/udp           # authorization daemon
EOF

expect $EXP_DEBUG -c "
    spawn ./torque.setup $torque_user
    expect {
        \"y/(n)?\" {
            send \"y\r\"
        }
    }
    catch wait result
    "
killall -TERM pbs_server >/dev/null 2>&1 || :
cd /tmp
rm -rf torque

