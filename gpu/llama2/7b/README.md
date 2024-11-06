# MaxText Llama2 7b Model training with Docker

## Clone the maxtext repository

```bash
git clone https://github.com/AI-Hypercomputer/maxtext
```

## Build the base image

```bash
cd maxtext
bash docker_build_dependency_image.sh DEVICE=gpu
```

## Update the Docker file with the new base image

```bash
# update Dockerfile with the new base image
docker build -t xxxxxx .
```

## Push the image to the gcloud container registry

```bash
# refer to gcloud docs to create registry
docker push xxxxxx
```

## Run with A3 Machine

Update Dockerfile to the below CMD to add model_name

```bash
 CMD ["run_name=cienet-maxtext-llama-2-1vm-run", "hardware=gpu", "steps=10", "dcn_data_parallelism=1", "ici_fsdp_parallelism=8", "per_device_batch_size=1",  "max_target_length=4096",  "enable_checkpointing=true",  "attention=cudnn_flash_te",  "remat_policy=minimal_flash",  "use_iota_embed=true",  "scan_layers=false",  "async_checkpointing=false", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]
```

changed to

```bash
 CMD ["run_name=cienet-maxtext-llama-2-1vm-run", "model_name=llama2-7b", "hardware=gpu", "steps=10", "dcn_data_parallelism=1", "ici_fsdp_parallelism=8", "per_device_batch_size=1",  "max_target_length=4096",  "enable_checkpointing=true",  "attention=cudnn_flash_te",  "remat_policy=minimal_flash",  "use_iota_embed=true",  "scan_layers=false",  "async_checkpointing=false", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]
```