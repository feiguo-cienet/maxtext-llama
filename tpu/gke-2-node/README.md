# Maxtext Modeling training with GKE - Multiple Slices (Two Slices)

You will get to do the following jobs:

*   Build Docker Image for Maxtext Model Training
*   Create a GKE cluster with multiple sclices TPU nodepool
*   Run a Kubernetes JobSet to train Maxtext llama2-7b/llama3.1-8b model using TPU

## Build Maxtext Model Training Image

### Clone the maxtext repository

```bash
git clone https://github.com/AI-Hypercomputer/maxtext
```

### Build the base image for TPU

```bash
cd maxtext
bash docker_build_dependency_image.sh
```

### Update the Docker file with the new base image

```bash
# update Dockerfile with the new base image
docker build -t xxxxxx .
```

### Push the image to the gcloud container registry

```bash
# refer to gcloud docs to create registry
docker push xxxxxx
```


## Creating the GKE cluster with multiple slices nodepools
Let’s start by setting a few environment variables that will be used throughout this post. You should modify these variables to meet your environment and needs.

Run the following commands to set the env variables and make sure to replace `<my-project-id>`:

```bash
gcloud config set project <my-project-id>
export PROJECT_ID=$(gcloud config get project)
export REGION=us-west1
export BUCKET_NAME=cienet-maxtext-llama-logger
export SERVICE_ACCOUNT="maxtext-gke-tpu@${PROJECT_ID}.iam.gserviceaccount.com"
```

> Note: You might have to rerun the export commands if for some reason you reset your shell and the variables are no longer set. This can happen for example when your Cloud Shell disconnects.

Create the GKE cluster by running:
```bash
gcloud container clusters create maxtext-gke-tpu-v5e-cluster --location ${REGION} \
  --workload-pool ${PROJECT_ID}.svc.id.goog \
  --enable-ip-alias \
  --node-locations=${REGION}-c \
  --scopes storage-rw
```


Let’s create two slices nodepool for our finetuning which will use TPU v5e.
For training Llama 2-7b Model, Create a multiple slices with two `tpuv5e-8` nodepool by running:
```bash
gcloud container node-pools create tpu-v5e-8-1 --cluster maxtext-gke-tpu-v5e-cluster \
  --machine-type ct5lp-hightpu-8t \
  --num-nodes=1 \
  --node-locations ${REGION}-c \
  --region ${REGION} \
  --scopes storage-rw

  gcloud container node-pools create tpu-v5e-8-2 --cluster maxtext-gke-tpu-v5e-cluster \
  --machine-type ct5lp-hightpu-8t \
  --num-nodes=1 \
  --node-locations ${REGION}-c \
  --region ${REGION} \
  --scopes storage-rw
```

Need update the default node pool to install the JobSet:
```bash
gcloud container node-pools update default-pool \
    --cluster maxtext-gke-tpu-v5e-cluster \
    --machine-type n2-standard-4 \
    --disk-type pd-balanced \
    --disk-size 100 \
    --region ${REGION}
```


## Run a Kubernetes job to train maxtext model

### Configuring GCS and required permissions

Create GCS bucket to store our models checkpoints and metrics if it's not created:
```bash
gcloud storage buckets create gs://${BUCKET_NAME}
```

The model loading Job will write to GCS. So let’s create a Google Service Account that has read and write permissions to the GCS bucket. Then create a Kubernetes Service Account named `maxtext-gke-tpu` that is able to use the Google Service Account.

To do this, first create a new Google Service Account:
```bash
gcloud iam service-accounts create maxtext-gke-tpu

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/logging.admin

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/logging.logWriter

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/storage.admin

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/container.admin

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/monitoring.admin
```

Verify the roles are set correctly:
```bash
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --format='table(bindings.role)' \
    --filter="bindings.members:${SERVICE_ACCOUNT}"
```

Assign the required GCS permissions to the Google Service Account:
```bash
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
  --member="serviceAccount:${SERVICE_ACCOUNT}" --role=roles/storage.admin
```

Allow the Kubernetes Service Account `maxtext-gke-tpu` in the `default` namespace to use the Google Service Account:
```bash
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT} \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[default/maxtext-gke-tpu]"
```

Create a new Kubernetes Service Account:
```bash
kubectl create serviceaccount maxtext-gke-tpu
kubectl annotate serviceaccount maxtext-gke-tpu iam.gke.io/gcp-service-account=maxtext-gke-tpu@${PROJECT_ID}.iam.gserviceaccount.com
```


Let's use a Kubernetes JobSet to train the model using multiple slices TPU.

Install the JobSet CRD:
```bash
export VERSION=v0.7.0
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/$VERSION/manifests.yaml

```

Run the model training Job:
```bash
kubectl apply -f train-llama2-7b.yaml
```

Verify that the file Job was created and that `$IMAGE` and `$BUCKET_NAME` got replaced with the correct values. A Pod should have been created, which you can verify by running:
```bash
kubectl get pod
kubectl describe pod -l job-name=model-training-maxtext-jobset-model-training-maxtext-0
kubectl describe pod -l job-name=model-training-maxtext-jobset-model-training-maxtext-1
```

Once the Pod gets into running state you can watch the logs of the training:
```bash
kubectl logs -f -l job-name=model-training-maxtext-jobset-model-training-maxtext-0
kubectl logs -f -l job-name=model-training-maxtext-jobset-model-training-maxtext-1
```

You can watch the training steps and observe the loss go down over time.