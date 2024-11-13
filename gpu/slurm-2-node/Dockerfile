FROM us-docker.pkg.dev/hpc-test-2-438108/maxtext-base-image/base

WORKDIR /deps

RUN git clone https://github.com/AI-Hypercomputer/maxtext

ENV NNODES=2
ENV NODE_RANK=1
ENV JAX_COORDINATOR_IP=10.128.0.36
ENV JAX_COORDINATOR_PORT=6222
ENV GPUS_PER_NODE=8
ENV XLA_PYTHON_CLIENT_PREALLOCATE=true
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.85
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

ENV XLA_FLAGS="--xla_dump_to=./hlo_dumps --xla_dump_hlo_pass_re=.* \
  --xla_gpu_enable_latency_hiding_scheduler=false --xla_gpu_enable_triton_gemm=false \
 --xla_gpu_graph_level=0 --xla_gpu_enable_highest_priority_async_stream=true \
 --xla_gpu_all_reduce_combine_threshold_bytes=134217728 --xla_gpu_all_gather_combine_threshold_bytes=134217728 \
 --xla_gpu_reduce_scatter_combine_threshold_bytes=67108864 --xla_gpu_enable_pipelined_all_gather=true \
 --xla_gpu_enable_pipelined_reduce_scatter=true --xla_gpu_enable_pipelined_all_reduce=true \
 --xla_gpu_enable_while_loop_double_buffering=true --xla_gpu_enable_triton_softmax_fusion=false \
 --xla_gpu_enable_all_gather_combine_by_dim=false --xla_gpu_enable_reduce_scatter_combine_by_dim=false \
 --xla_disable_hlo_passes=rematerialization"

 ENTRYPOINT ["python3", "/deps/maxtext/MaxText/train.py", "/deps/maxtext/MaxText/configs/gpu_smoke_test.yml"]
 CMD ["run_name=cienet-maxtext-llama-2-2vm-run", "hardware=gpu", "steps=300", "dcn_data_parallelism=2", "ici_fsdp_parallelism=8", "per_device_batch_size=1", "enable_checkpointing=false",  "async_checkpointing=false", "dataset_type=synthetic", "base_output_directory=gs://cienet-maxtext-llama-logger"]