#!/bin/bash

torque_version=6.0.4

set -x
set -e
yum install -y boost-devel \
    libxml2-devel \
    make openssl-devel \
    rpm-build \
    git \
    vixie-cron \
    openmpi-devel
yum groupinstall -y 'Development Tools'
yum clean all
cd /tmp
git clone -b $torque_version https://github.com/adaptivecomputing/torque.git
cd /tmp/torque
./autogen.sh
./configure --prefix=/usr
make rpm
cp -r /root/rpmbuild/RPMS/$(uname -m) /tmp/PKG
rm -rf /root/rpmbuild/RPMS/$(uname -m)
cd /tmp/PKG
rpm -ivh *.rpm
rm -rf *.rpm
cd /tmp
rm -rf torque

