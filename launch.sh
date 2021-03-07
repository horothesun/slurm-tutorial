#!/bin/bash

# build images

docker build -t docker-slurm .
(
  cd docker_slurmctld_build/
  docker build -t docker-slurmctld .
)
(
  cd docker_slurmd_build/
  docker build -t docker-slurmd .
)


# deploy cluster

docker run \
  --privileged \
  --add-host ctld:172.17.0.2 \
  --add-host c0:172.17.0.3 \
  --add-host c1:172.17.0.4 \
  --add-host c2:172.17.0.5 \
  -d -it --rm \
  -p 11134:22 \
  -e "container=docker" \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  -v $(pwd)/ctld_ext:/opt/slurm-17.11.9/ext \
  --name ctld --hostname ctld \
  docker-slurmctld
sleep 2

docker run \
  --privileged \
  --add-host ctld:172.17.0.2 \
  --add-host c0:172.17.0.3 \
  --add-host c1:172.17.0.4 \
  --add-host c2:172.17.0.5 \
  -d -it --rm \
  -p 11135:22 \
  -e "container=docker" \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --name c0 --hostname c0 \
  docker-slurmd
sleep 2

docker run \
  --privileged \
  --add-host ctld:172.17.0.2 \
  --add-host c0:172.17.0.3 \
  --add-host c1:172.17.0.4 \
  --add-host c2:172.17.0.5 \
  -d -it --rm \
  -p 11136:22 \
  -e "container=docker" \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --name c1 --hostname c1 \
  docker-slurmd
sleep 2

docker run \
  --privileged \
  --add-host ctld:172.17.0.2 \
  --add-host c0:172.17.0.3 \
  --add-host c1:172.17.0.4 \
  --add-host c2:172.17.0.5 \
  -d -it --rm \
  -p 11137:22 \
  -e "container=docker" \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --name c2 --hostname c2 \
  docker-slurmd
