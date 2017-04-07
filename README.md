This is an isolated TORQUE cluster.

------------------------------------------------------------------------------

When launched in "Server" mode, TORQUE will automatically start on the
master node and all slave nodes.

------------------------------------------------------------------------------

In "Batch" mode, there are two ways to start TORQUE:


- From the master node, launch TORQUE on all nodes:

`/usr/local/scripts/torque/launch_all.sh`


- From each individual node, launch TORQUE individually:

`sudo /usr/local/scripts/torque/launch.sh`

------------------------------------------------------------------------------

You can check the status of the nodes with:

`pbsnodes`

You can check the queue status with:

`qstat -at`

or submit a job from any node in the cluster with:

`echo 'echo "hello world"' | qsub`

------------------------------------------------------------------------------

