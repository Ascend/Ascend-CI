### Backend Operator Support Summary

| Operator | Status |
| --- | --- |
| ABS | ✅ |
| ACC | ✅ |
| ADD | ✅ |
| ADD1 | ✅ |
| ARANGE | ✅ |
| ARGMAX | ✅ |
| ARGSORT | ✅ |
| CLAMP | ✅ |
| CONCAT | ✅ |
| CONV_TRANSPOSE_1D | ✅ |
| COS | ✅ |
| COUNT_EQUAL | ✅ |
| CROSS_ENTROPY_LOSS | ✅ |
| DIAG_MASK_INF | ✅ |
| DIV | ✅ |
| DUP | ✅ |
| ELU | ✅ |
| EXP | ✅ |
| GEGLU | ✅ |
| GEGLU_ERF | ✅ |
| GEGLU_QUICK | ✅ |
| GELU | ✅ |
| GELU_ERF | ✅ |
| GELU_QUICK | ✅ |
| GROUP_NORM | ✅ |
| HARDSIGMOID | ✅ |
| HARDSWISH | ✅ |
| IM2COL | ✅ |
| L2_NORM | ✅ |
| LEAKY_RELU | ✅ |
| LOG | ✅ |
| MEAN | ✅ |
| MUL | ✅ |
| NEG | ✅ |
| NORM | ✅ |
| PAD_REFLECT_1D | ✅ |
| REGLU | ✅ |
| RELU | ✅ |
| REPEAT | ✅ |
| RMS_NORM | ✅ |
| RMS_NORM_MUL_ADD | ✅ |
| ROPE | ✅ |
| SGN | ✅ |
| SIGMOID | ✅ |
| SILU | ✅ |
| SIN | ✅ |
| SOFTCAP | ✅ |
| SQR | ✅ |
| SQRT | ✅ |
| SSM_CONV | ✅ |
| STEP | ✅ |
| SUB | ✅ |
| SUM_ROWS | ✅ |
| SWIGLU | ✅ |
| TANH | ✅ |
| TIMESTEP_EMBEDDING | ✅ |
| CONT | 🟡 |
| CONV_2D | 🟡 |
| CONV_2D_DW | 🟡 |
| CONV_TRANSPOSE_2D | 🟡 |
| CPY | 🟡 |
| CROSS_ENTROPY_LOSS_BACK | 🟡 |
| FLASH_ATTN_EXT | 🟡 |
| GATED_LINEAR_ATTN | 🟡 |
| GET_ROWS | 🟡 |
| GET_ROWS_BACK | 🟡 |
| MUL_MAT | 🟡 |
| MUL_MAT_ID | 🟡 |
| OPT_STEP_ADAMW | 🟡 |
| PAD | 🟡 |
| POOL_2D | 🟡 |
| REPEAT_BACK | 🟡 |
| RMS_NORM_BACK | 🟡 |
| ROLL | 🟡 |
| ROPE_BACK | 🟡 |
| RWKV_WKV6 | 🟡 |
| RWKV_WKV7 | 🟡 |
| SCALE | 🟡 |
| SET | 🟡 |
| SET_ROWS | 🟡 |
| SILU_BACK | 🟡 |
| SOFT_MAX | 🟡 |
| SOFT_MAX_BACK | 🟡 |
| SSM_SCAN | 🟡 |
| SUM | 🟡 |
| UPSCALE | 🟡 |
| OUT_PROD | ❌ |

Tips: ✅ supported, 🟡 partially supported, ❌ fail, ❓ unsupported, 🔍 unknown

### Operators with changed status

| Operator | Previous | Current |
| --- | --- | --- |
| OUT_PROD | partial (🟡) | fail (❌) |
| SSM_CONV | partial (🟡) | supported (✅) |

#### OUT_PROD log (partial -> fail)
```text
new_pool_for_device: device 0 use vmm pool
Testing 2 devices

Backend 1/2: CANN0
  Device description: Ascend910B1
  Device memory: 62420 MB (62055 MB free)

/__w/Ascend-CI/Ascend-CI/llama.cpp/ggml/src/ggml-cann/aclnn_ops.cpp:3723: GGML_ASSERT(dst->ne[0] == nr) failed
libggml-base.so.0(+0x151a4)[0xffff9e6951a4]
libggml-base.so.0(ggml_print_backtrace+0x21c)[0xffff9e69565c]
libggml-base.so.0(ggml_abort+0x134)[0xffff9e695824]
libggml-cann.so.0(_Z18ggml_cann_ssm_convR25ggml_backend_cann_contextP11ggml_tensor+0x414)[0xffff9e051a84]
libggml-cann.so.0(+0x26820)[0xffff9e056820]
libggml-cann.so.0(+0x27358)[0xffff9e057358]
libggml-base.so.0(ggml_backend_graph_compute+0x14)[0xffff9e6ab184]
libggml-base.so.0(ggml_backend_compare_graph_backend+0x170)[0xffff9e6afc70]
./test-backend-ops(+0x80f7c)[0xaaaac70c0f7c]
./test-backend-ops(+0x36618)[0xaaaac7076618]
./test-backend-ops(+0x16a10)[0xaaaac7056a10]
/lib/aarch64-linux-gnu/libc.so.6(+0x273fc)[0xffff9e1f73fc]
/lib/aarch64-linux-gnu/libc.so.6(__libc_start_main+0x98)[0xffff9e1f74cc]
./test-backend-ops(+0x180f0)[0xaaaac70580f0]
```

#### SSM_CONV log (partial -> supported)
```text
new_pool_for_device: device 0 use vmm pool
Testing 2 devices

Backend 1/2: CANN0
  Device description: Ascend910B1
  Device memory: 62420 MB (62051 MB free)

  SSM_CONV(type=f32,ne_a=[3,1024,1,1],ne_b=[3,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[6,1024,1,1],ne_b=[3,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[3,1024,4,1],ne_b=[3,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[3,1536,1,1],ne_b=[3,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[6,1536,1,1],ne_b=[3,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[3,1536,4,1],ne_b=[3,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[3,2048,1,1],ne_b=[3,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[6,2048,1,1],ne_b=[3,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[3,2048,4,1],ne_b=[3,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,1024,1,1],ne_b=[4,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[8,1024,1,1],ne_b=[4,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,1024,4,1],ne_b=[4,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,1536,1,1],ne_b=[4,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[8,1536,1,1],ne_b=[4,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,1536,4,1],ne_b=[4,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,2048,1,1],ne_b=[4,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[8,2048,1,1],ne_b=[4,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[4,2048,4,1],ne_b=[4,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,1024,1,1],ne_b=[9,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[18,1024,1,1],ne_b=[9,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,1024,4,1],ne_b=[9,1024,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,1536,1,1],ne_b=[9,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[18,1536,1,1],ne_b=[9,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,1536,4,1],ne_b=[9,1536,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,2048,1,1],ne_b=[9,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[18,2048,1,1],ne_b=[9,2048,1,1]): [1;32mOK[0m
  SSM_CONV(type=f32,ne_a=[9,2048,4,1],ne_b=[9,2048,1,1]): [1;32mOK[0m
  27/27 tests passed
  Backend CANN0: [1;32mOK[0m
Backend 2/2: CPU
  Skipping CPU backend
2/2 backends passed
[1;32mOK[0m
```
