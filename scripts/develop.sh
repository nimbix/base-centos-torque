#!/bin/sh

sudo service sshd start

echo "SSH is now running. This is an ephemeral environment. All persistent data should be stored in /data."

tail -f /dev/null
