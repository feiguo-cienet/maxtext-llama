# Maxtext Modeling training with GKE - single instances

You will get to do the following jobs:

*   Create a GKE cluster with an autoscaling L4 GPU nodepool
*   Run a Kubernetes Job to train Maxtext default model using L4 GPUs


## Creating the GKE cluster with L4 nodepools
Let’s start by setting a few environment variables that will be used throughout this post. You should modify these variables to meet your environment and needs.

Run the following commands to set the env variables and make sure to replace `<my-project-id>`:

```bash
gcloud config set project <my-project-id>
export PROJECT_ID=$(gcloud config get project)
export REGION=us-central1
export BUCKET_NAME=cienet-maxtext-llama-logger
export SERVICE_ACCOUNT="maxtext-gke-l4@${PROJECT_ID}.iam.gserviceaccount.com"
```

> Note: You might have to rerun the export commands if for some reason you reset your shell and the variables are no longer set. This can happen for example when your Cloud Shell disconnects.

Create the GKE cluster by running:
```bash
gcloud container clusters create maxtext-gke-l4 --location ${REGION} \
  --workload-pool ${PROJECT_ID}.svc.id.goog \
  --enable-image-streaming --enable-shielded-nodes \
  --shielded-secure-boot --shielded-integrity-monitoring \
  --enable-ip-alias \
  --node-locations=${REGION}-a \
  --labels=ai-on-gke=maxtext-gke-l4 \
  --addons GcsFuseCsiDriver
```


Let’s create a nodepool for our finetuning which will use 8 L4 GPUs per VM.
Create the `g2-standard-96` nodepool by running:
```bash
gcloud container node-pools create g2-standard-96 --cluster maxtext-gke-l4 \
  --accelerator type=nvidia-l4,count=8,gpu-driver-version=latest \
  --machine-type g2-standard-96 \
  --ephemeral-storage-local-ssd=count=8 \
  --enable-autoscaling --enable-image-streaming \
  --num-nodes=2 --min-nodes=2 --max-nodes=2 \
  --shielded-secure-boot \
  --shielded-integrity-monitoring \
  --labels=ai-on-gke=maxtext-gke-l4 \
  --node-locations ${REGION}-a --region ${REGION}
```


## Run a Kubernetes job to train maxtext model


### Configuring GCS and required permissions

Create GCS bucket to store our models checkpoints and metrics if it's not created:
```bash
gcloud storage buckets create gs://${BUCKET_NAME}
```

The model loading Job will write to GCS. So let’s create a Google Service Account that has read and write permissions to the GCS bucket. Then create a Kubernetes Service Account named `maxtext-gke-l4` that is able to use the Google Service Account.

To do this, first create a new Google Service Account:
```bash
gcloud iam service-accounts create maxtext-gke-l4

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SERVICE_ACCOUNT} \
    --role=roles/container.admin \
    --role=roles/logging.admin \
    --role=roles/logging.logWriter \
    --role=roles/monitoring.admin \
    --role=roles/storage.admin
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

Allow the Kubernetes Service Account `maxtext-gke-l4` in the `default` namespace to use the Google Service Account:
```bash
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT} \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[default/maxtext-gke-l4]"
```

Create a new Kubernetes Service Account:
```bash
kubectl create serviceaccount maxtext-gke-l4
kubectl annotate serviceaccount maxtext-gke-l4 iam.gke.io/gcp-service-account=maxtext-gke-l4@${PROJECT_ID}.iam.gserviceaccount.com
```


Let's use a Kubernetes Job to train the model.

Run the model training Job:
```bash
envsubst < train.yaml | kubectl apply -f -
```

Verify that the file Job was created and that `$IMAGE` and `$BUCKET_NAME` got replaced with the correct values. A Pod should have been created, which you can verify by running:
```bash
kubectl describe pod -l job-name=model-training-job
```

You should see a `pod triggered scale-up` message under Events after about 30 seconds. Then it will take another 2 minutes for a new GKE node with 8 x L4 GPUs to spin up. Once the Pod gets into running state you can watch the logs of the training:
```bash
kubectl logs -f -l job-name=model-training-job
```

You can watch the training steps and observe the loss go down over time.