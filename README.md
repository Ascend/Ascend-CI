# ONNXRuntime Ascend CI system

This is the repo to run ONNXRuntime CI jobs with Ascend backend.
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

##### Issue #2 [Closed] 
Update on 2023.07.18  
PR [#16506](https://github.com/microsoft/onnxruntime/pull/16506) changed the public constructor function `MLFloat16(uint16_t x)` to private, and added a public function `MLFloat16::FromBits(uint16_t x)` in the file `include/onnxruntime/core/framework/float16.h`, which broke the CANN CI. This has been fixed by PR [#16733](https://github.com/microsoft/onnxruntime/pull/16733) by replacing the constructor function `MLFloat16()` with the public member function `FromBits()` in the file `onnxruntime/core/providers/cann/cann_common.cc`~~, but is waiting for upstream merge~~ and this PR has been merged into upstream.

##### Issue #1 [Closed] 
Update on 2023.07.06  
This [PR](https://github.com/microsoft/onnxruntime/pull/15833) refactored the ExecutionProvider API for memory management, and broke the CANN EP build. This has been fixed by this [PR](https://github.com/microsoft/onnxruntime/pull/16490)~~, but is waiting for upstream merge~~.

##### Issue #0 [Closed]
Update on 2023.06.08  
This [PR](https://github.com/microsoft/onnxruntime/pull/14731) introduced a missing registration of CANN Identity operator for version greater than 14. It has been fixed in this [PR](https://github.com/microsoft/onnxruntime/pull/16210).