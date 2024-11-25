# MaxText Llama2 7b Model training with Docker

## Clone the maxtext repository

```bash
git clone https://github.com/AI-Hypercomputer/maxtext
```

## Build the base image for TPU

```bash
cd maxtext
bash docker_build_dependency_image.sh
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

## Run with Powerful TPU for Llama 2 model

Update Dockerfile to the below CMD to add model_name

```bash
CMD ["run_name=cienet-maxtext-llama-2-tpu-1vm-run", "steps=30",  "attention=dot_product", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]
```

changed to

```bash
CMD ["run_name=cienet-maxtext-llama-2-tpu-1vm-run", "model_name=llama2-7b", "steps=30",  "attention=dot_product", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]
```