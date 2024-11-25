# MaxText Llama2 7b Model training with TPU VM

## Slurm Cluster setup

```bash
ghpc create slurm-docker-tpu-maxtext.yaml --vars project_id=$(gcloud config get-value project) --force
ghpc deploy slurm-maxtext-tpu --auto-approve
```

Once the cluster is setup ready, SSH into the controller node:

```bash
cd /opt/tpu-test
sbatch run_maxtext.sh
```