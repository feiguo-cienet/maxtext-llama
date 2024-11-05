FROM us-docker.pkg.dev/hpc-test-2-438108/maxtext-base-image/base

WORKDIR /deps

RUN git clone https://github.com/AI-Hypercomputer/maxtext

ENV XLA_PYTHON_CLIENT_PREALLOCATE=true
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.9
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

ENTRYPOINT ["python3 maxtext/MaxText/train.py maxtext/MaxText/configs/base.yml run_name=cienet-maxtext-llama-2-1vm-run hardware=gpu steps=10 dcn_data_parallelism=1 ici_fsdp_parallelism=8 per_device_batch_size=1 max_target_length=4096   enable_checkpointing=true attention=cudnn_flash_te remat_policy=minimal_flash use_iota_embed=true scan_layers=false dataset_type=synthetic async_checkpointing=false base_output_directory=gs://cienet-maxtext-llama-logger"]