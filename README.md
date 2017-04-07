This is an isolated TORQUE cluster.

------------------------------------------------------------------------------

Launch TORQUE on all nodes:

`/usr/local/scripts/torque/launch_all.sh`

OR

Launch TORQUE nodes individually:

`/usr/local/scripts/torque/launch.sh`

------------------------------------------------------------------------------

You can check the status of the nodes with:

`pbsnodes`

You can check the queue status with:

`qstat -at`

or submit a job from any node in the cluster with:

`echo 'echo "hello world"' | qsub`

