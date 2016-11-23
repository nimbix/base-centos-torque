This is an isolated TORQUE cluster. To start the TORQUE cluster, first call `/usr/local/scripts/torque/setup_torque.sh`

You can check the queue status with:

`qstat -at`

or submit a job from any node in the cluster with:

`echo 'echo "hello world"' | qsub`

