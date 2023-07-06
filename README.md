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

##### Issue #1 [Closed] 
Updated on 2023.07.06  
This [PR](https://github.com/microsoft/onnxruntime/pull/15833) refactored the ExecutionProvider API for memory management, and broke the CANN EP build. This has been fixed by this [PR](https://github.com/microsoft/onnxruntime/pull/16490)~~, but is waiting for upstream merge~~.

##### Issue #0 [Closed]
Updated on 2023.06.08  
This [PR](https://github.com/microsoft/onnxruntime/pull/14731) introduced a missing registration of CANN Identity operator for version greater than 14. It has been fixed in this [PR](https://github.com/microsoft/onnxruntime/pull/16210).