FROM us-docker.pkg.dev/hpc-test-2-438108/maxtext-base-image/base-tpu

WORKDIR /deps

RUN git clone https://github.com/AI-Hypercomputer/maxtext

ENV NNODES=2
ENV NODE_RANK=1
ENV JAX_COORDINATOR_IP=10.128.0.36
ENV JAX_COORDINATOR_PORT=6222
ENV GPUS_PER_NODE=8

ENTRYPOINT ["python3", "/deps/maxtext/MaxText/train.py", "/deps/maxtext/MaxText/configs/base.yml"]
CMD ["run_name=cienet-maxtext-llama-2-tpu-1vm-run", "steps=30",  "attention=dot_product", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]