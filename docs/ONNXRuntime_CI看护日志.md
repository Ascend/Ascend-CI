**Github Action 每两月需重启一次**

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
