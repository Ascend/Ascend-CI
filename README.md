# ONNXRuntime Ascend CI system

This is the repo to run ONNXRuntime CI jobs with Ascend backend. The ONNXRuntime source code is in `main` branch from `microsoft/onnxruntime` and run Ascend related build, test jobs daily.

------------------------------------------------------------

## Environment Information

|  Key   | Value  |
|  ----  | ----  |
| Version  | latest |
| openEuler version | 22.03 LTS SP1 |
| Arch  | arm64 |
| Action | **Build from source**, **Unit test** |
| Period | UTC 1200 daily |
| Recheck By Hand | comment 'recheck' in any issue |

## CI Status

![Linux Ascend](https://github.com/Ascend/onnxruntime/actions/workflows/build-and-test.yaml/badge.svg)

