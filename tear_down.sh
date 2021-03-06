#!/bin/bash

docker kill c0 c1 c2 ctld
docker ps -a

docker rmi docker-slurmctld docker-slurmd docker-slurm
docker images
