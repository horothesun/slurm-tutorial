# Deploy a Slurm cluster upon a PC using Docker

This tutorial provides the basic blocks to create a Slurm cluster based on Docker.
It can be used as a tool to train administrators to configure and deploy different Slurm functionalities and to help users to learn the different ways they can use Slurm under specific configurations.

#### Prerequisites

- You need to have Docker installed, and an internet connection for at least the first deployment.
- In case you already have the docker-slurm image no internet connection is needed.

### 1. Download the tutorial code

You can either download the code in zip format by using the Download ZIP button of GitHub or use the git command to clone the repository.

```bash
git clone https://github.com/horothesun/slurm-tutorial.git
```

### 2. Launch the deployment of the cluster

Go to the directory of the code.

```bash
cd slurm-tutorial
```

You can see the procedure the deployment is going to follow by opening the `launch.sh` file in that directory.

In the first usage of the script and if you don't have docker-slurm image the procedure will build everything from scratch "build images step".
This might take some time depending on the quality of the connection.

There is one main docker image called docker-slurm that contains all packages and 2 other images which specialize on the role of the node within the cluster.
The docker-slurmctld image will be used for the controller side (slurmctld and slurmdbd daemons) whereas the docker-slurmd image for the compute nodes (slurmd daemon).
Once the build process is finished the procedure continues in deploying the cluster based on the images created "deploy cluster step" .

Execute the `launch.sh` script by using the following command:

```bash
./launch.sh
```

When the above script has finished execution without errors the cluster will be ready for usage.

### 3. Connect to the deployed cluster

Connect on the controller machine:

```bash
docker exec -t -i ctld /bin/bash
```

If everything worked fine until now you will be connected upon the controller of the cluster.

```
[root@ctld slurm-17.11.9]#
```

You can start using the Slurm cluster by issuing different Slurm commands:

```
[root@ctld slurm-17.11.9]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 1-00:00:00      4   idle c[0-3]
[root@ctld slurm-17.11.9]# srun -n3 -N3 /bin/hostname
c0
c2
c1
```

#### Change Slurm configuration

The configuration files for Slurm can be found under /usr/local/etc/

For a configuration parameter to take effect you can make changes on the slurm.conf file of the controller, then transfer the file on all compute nodes and restart the daemons. For this you can use `clush` command which exists within the already deployed environment.

```
[root@ctld slurm-17.11.9]# clush -bw c[0-3] -c /usr/local/etc/slurm.conf
[root@ctld slurm-17.11.9]# clush -bw c[0-3] pkill slurmd
[root@ctld slurm-17.11.9]# pkill slurmctld
[root@ctld slurm-17.11.9]# clush -bw c[0-1] slurmd
[root@ctld slurm-17.11.9]# slurmctld
```

### 4. Activate Slurm database with slurmdbd daemon

By default the usage of the database is deactivated. However the database in Slurm is a core feature upon which many features rely such as users accounts and limitations, jobs accounting and reporting along with scheduling algorithms such as fairsharing and preemption.

While on the controller. Execute the following script:

```
[root@ctld slurm-17.11.9]# /opt/slurm-17.11.9/launch_DB.sh
```

This will change the slurm.conf file to activate the mysql database, it will initialize the slurm database and restart daemons for the changes to take effect.

You can now use the `sacct` command to follow the accounting of jobs.

```
[root@ctld slurm-17.11.9]# sacct
       JobID    JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- -------- 
2              hostname     normal       root          3  COMPLETED      0:0 
4              hostname     normal       root          3  COMPLETED      0:0 
```

#### Use the cluster as a simple user

root has advanced privileges when using Slurm commands. You can change to user guest in order to see how a simple user can make use of the Slurm cluster.

```
[root@ctld slurm-17.11.9]# su guest
[guest@ctld slurm-17.11.9]$
[guest@ctld slurm-17.11.9]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 1-00:00:00      4   idle c[0-3]
[guest@ctld slurm-17.11.9]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[guest@ctld slurm-17.11.9]$ srun -n3 /bin/hostname
c0
c0
c0
[guest@ctld slurm-17.11.9]$ sacct
       JobID    JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- -------- 
5              hostname     normal                     3  COMPLETED      0:0 
```

For example a simple user doesn't have the right to see the accounting of root's jobs.

Since ssh is activate within the node and it is possible to go around from the controller to the compute nodes with ssh. Here is the guest password `"guest1234"`.

#### Tearing down the cluster

To tear-down the cluster, run

```bash
./tear_down.sh
```

### 5. Hands-ON: Experiment with Slurm configuration and usage through exercises

Now that the Slurm cluster is up and running you can start experimenting following the tutorial and the hands-on exercises available on the slides here: [SLURM_Tutorial_Cluster2016.pdf](https://github.com/RJMS-Bull/slurm-tutorial/blob/master/SLURM_Tutorial_Cluster2016.pdf).
