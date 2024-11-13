#!/bin/bash

docker run --privileged --gpus all --shm-size 2g --network host \
-e NODE_RANK=$SLURM_NODEID \
-e JAX_COORDINATOR_IP=$1 \
us-docker.pkg.dev/hpc-test-2-438108/maxtext-base-image/llama2-7b-2node