# Ascend CI system
This is the repo to run CI jobs with Ascend backend.

- [CI 看护日志](https://github.com/Ascend/Ascend-CI/blob/main/docs/ONNXRuntime_CI%E7%9C%8B%E6%8A%A4%E6%97%A5%E5%BF%97.md)
- [ONNXRuntime 发包指导](https://github.com/cosdt/Quora/issues/8)

## ONNXRuntime Ascend CI
The ONNXRuntime source code is from `main` branch of `microsoft/onnxruntime` and will be run and tested daily with Ascend related.

------------------------------------------------------------

| Key  | Value |
| :---: | :---: |
| CPU  | Intel Xeon x86 |
| NPU | Ascend310 |
| OS | openEuler |
| Period | UTC 1200 daily |
| Branch  | main |
| Status  | ![Linux Ascend](https://github.com/Ascend/onnxruntime/actions/workflows/build-and-test.yaml/badge.svg) |
| Recheck By Hand | comment 'recheck' in any issue |

### Known Issue

##### Issuse #4 [Opened]
Update on 2023.03.26  
New provider option: flag of `dump_om_model`.  
When building an onnx model with CANN EP, the intermediate OM(offline model for Ascend NPU) is automatically saved. There are some users don't want to dump OM when resources are limited.  
PR [#20075](https://github.com/microsoft/onnxruntime/pull/20075) has resovled this situation with `dump_om_model=False`.  
PR [#20138](https://github.com/microsoft/onnxruntime/pull/20138) for the doc update.

##### Issue #3 [Closed]
Update on 2024.03.16  
PR [#17365](https://github.com/microsoft/onnxruntime/pull/17365) avioded using patchelf but lost `cann_dependencies`, PR [#19929](https://github.com/microsoft/onnxruntime/pull/19929) adds `cann_dependencies` to avoid require cann libraries when repairing wheel.

##### Issue #2 [Closed] 
Update on 2023.07.18  
PR [#16506](https://github.com/microsoft/onnxruntime/pull/16506) changed the public constructor function `MLFloat16(uint16_t x)` to private, and added a public function `MLFloat16::FromBits(uint16_t x)` in the file `include/onnxruntime/core/framework/float16.h`, which broke the CANN CI. This has been fixed by PR [#16733](https://github.com/microsoft/onnxruntime/pull/16733) by replacing the constructor function `MLFloat16()` with the public member function `FromBits()` in the file `onnxruntime/core/providers/cann/cann_common.cc`~~, but is waiting for upstream merge~~ and this PR has been merged into upstream.

##### Issue #1 [Closed] 
Update on 2023.07.06  
This [PR](https://github.com/microsoft/onnxruntime/pull/15833) refactored the ExecutionProvider API for memory management, and broke the CANN EP build. This has been fixed by this [PR](https://github.com/microsoft/onnxruntime/pull/16490)~~, but is waiting for upstream merge~~.

##### Issue #0 [Closed]
Update on 2023.06.08  
This [PR](https://github.com/microsoft/onnxruntime/pull/14731) introduced a missing registration of CANN Identity operator for version greater than 14. It has been fixed in this [PR](https://github.com/microsoft/onnxruntime/pull/16210).

## Deepspeed Ascend CI
The Deepspeed source code is from `main` branch of `microsoft/deepspeed` and will be run and tested daily with Ascend related.

------------------------------------------------------------

| Key  | Value |
| :---: | :---: |
| CPU  | Arrch64 |
| NPU | Ascend910B |
| OS | Ubantu |
| Period | UTC 1200 daily |
| Branch  | main |
| Status  | ![Deepspeed](https://github.com/Ascend/Ascend-CI/actions/workflows/deepspeed.yaml/badge.svg) |
| Recheck By Hand | comment 'recheck' in any issue |

## Pytorch Ascend CI
TBD
