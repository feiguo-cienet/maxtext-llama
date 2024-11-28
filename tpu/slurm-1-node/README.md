# MaxText Llama2 7b Model training with TPU VM

**NOTE: Since Slurmd on TPU VM is running as docker container. So running training job in container need Docker-In-Docker. The feasibility need further investigation.**

## Slurm Cluster setup

```bash
ghpc create slurm-tpu-maxtext.yaml --vars project_id=$(gcloud config get-value project) --force
ghpc deploy slurm-maxtext-tpu --auto-approve
```

Once the cluster is setup ready, SSH into the controller node and start the model training job:

**NOTE: Need copy the job shell script to $HOME directory.**

```bash
cd /opt/tpu-test
cp run_maxtext.sh ~/.
cd
sbatch run_maxtext.sh
```