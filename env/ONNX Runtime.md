# ONNX Runtime

## gcc&g++

```shell
add-apt-repository ppa:ubuntu-toolchain-r/test
apt update

apt install gcc-13 g++-13

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
```

## cmake

```shell
mkdir -p /root/devtoolsets/cmake && cd /root/devtoolsets/cmake

wget https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-linux-x86_64.tar.gz

tar -zxvf cmake-3.31.5-linux-x86_64.tar.gz --strip-components 1

update-alternatives --install /usr/bin/cmake cmake /root/devtoolset/cmake/bin/cmake 100
update-alternatives --install /usr/bin/ctest ctest /root/devtoolset/cmake/bin/ctest 100
```

## Python

```shell
add-apt-repository ppa:deadsnakes/ppa

apt install python3.10 -y
apt install python3.10-dev -y

update-alternatives --install /usr/local/bin/python python  /usr/bin/python3.10 100
update-alternatives --install /usr/local/bin/python3 python3  /usr/bin/python3.10 100

mkdir -p /root/devtoolsets/python && cd /root/devtoolsets/python
wget https://bootstrap.pypa.io/get-pip.py

python3 get-pip.py

```

## CANN

```shell
mkdir -p /root/devtoolsets/cann && cd /root/devtoolsets/cann

wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.0/Ascend-cann-toolkit_8.0.0_linux-x86_64.run?response-content-type=application/octet-stream -O toolkit_8.0.0.run
chmod +x toolkit_8.0.0.run

// 安装驱动依赖 
apt-get install -y make zlib1g zlib1g-dev openssl libsqlite3-dev libssl-dev libffi-dev unzip pciutils net-tools libblas-dev gfortran libblas3

// 安装python依赖
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple attrs numpy==1.24.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf scipy requests absl-py wheel typing_extensions
y

./toolkit_8.0.0.run --full
```

## ONNX Runtime

```shell
cd /root && mkdir Git.d && cd Git.d

git clone https://github.com/microsoft/onnxruntime.git --depth 1
cd onnxruntime
git remote rename origin upstream
git fetch --all & git rebase upstream/main
```

## Build && Test

```shell
pushd /root/Git.d/onnxruntime &&
source /usr/local/Ascend/ascend-toolkit/set_env.sh &&
./build.sh --allow_running_as_root --config RelWithDebInfo --build_shared_lib --parallel --use_cann --build_wheel --skip_tests &&
popd
```
