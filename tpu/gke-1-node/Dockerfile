FROM us-docker.pkg.dev/hpc-test-2-438108/maxtext-base-image/base-tpu

WORKDIR /deps

RUN git clone https://github.com/AI-Hypercomputer/maxtext

ENTRYPOINT ["python3", "/deps/maxtext/MaxText/train.py", "/deps/maxtext/MaxText/configs/base.yml"]
CMD ["run_name=cienet-maxtext-llama-2-tpu-1vm-run", "steps=30",  "attention=dot_product", "dataset_type=synthetic", "enable_checkpointing=true", "async_checkpointing=false", "base_output_directory=gs://cienet-maxtext-llama-logger"]