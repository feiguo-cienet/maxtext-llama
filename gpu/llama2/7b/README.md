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