**Github Action 每两月需重启一次**


-----

#### 2024.08.23 [Action #421]()
Error: cc: error: unrecognized command-line option ‘-mavxvnni’; did you mean ‘-mavx512vnni’?
解决方法： 错误原因及上游修复参考[PR](https://github.com/microsoft/onnxruntime/pull/21616)
本地修复手段为升级gcc版本
1.确保有昇腾芯片
2.Ubuntu 系统替换 openEuler 系统
  1.openEuler系统升级gcc
    报错`libonnxruntime providers.a(attention_utils.cc.o): defined in discarded section`,
    编译器有问题，openEuler对gcc版本兼容性不好，一个openEuler版本最好对应一个gcc版本
  2.ubuntu 18.04/20.04，
    太高的版本(22.04)安装A300-3010-npu-driver_23.0.0_linux-x86_64驱动报错: https://www.hiascend.com/forum/thread-0247127723630059066-1-1.html, https://www.hiascend.com/forum/thread-0270130649513967034-1-1.html
    升级 gcc, g++ 至 11.4
    升级 cmake 至 3.26.6
    升级 as 至 2.38
    安装驱动及cann, cann版本使用 Ascend-cann-toolkit_7.0.RC1_linux-x86_64
    python版本使用 3.8

-----

#### 2023.01.22 [Action #236](https://github.com/Ascend/Ascend-CI/actions/runs/7611053837/job/20725706992)
Error:
  ```shell
  Traceback (most recent call last):
    File "/root/Git.d/onnxruntime/tools/ci_build/build.py", line 74, in <module>
      _check_python_version()
    File "/root/Git.d/onnxruntime/tools/ci_build/build.py", line 62, in _check_python_version
      f"Invalid Python version. At least Python 3.{required_minor_version} is required. "
  __main__.UsageError: Invalid Python version. At least Python 3.8 is required. Actual Python version: 3.7.9 (default, Apr 12 2023, 10:26:48)
  [GCC 7.3.0]
  Error: Process completed with exit code 1.
  ```

解决方法： 更新 python 版本

-----

#### 2023.03.26 [Action #271](https://github.com/Ascend/Ascend-CI/actions/runs/8420082482/job/23054049914)
Error: `/bin/sh: Patch_EXECUTABLE-NOTFOUND: command not found`

解决方法：`yum install patch`
