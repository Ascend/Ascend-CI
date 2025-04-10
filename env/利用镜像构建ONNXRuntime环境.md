### 环境中各依赖版本

| Ubuntu            | 22.04          |
| ----------------- | -------------- |
| **宿主机CPU架构** | **arm**        |
| **Glibc**         | **2.35**       |
| **CANN**          | **8.0.0**      |
| **python**        | **3.10**       |
| **gcc/g++**       | **11.4.0以上** |
| **numpy**         | **1.24.0**     |
| **cmake**         | **3.29.7**     |



### 拉取CANN镜像

```
docker pull ascendai/cann:latest
```

### 

### docker run 参考命令

按照自己环境的对应路径进行调整

```bash
docker run  -d \
--name cann_container \
--device /dev/davinci1 \
--device /dev/davinci_manager \
--device /dev/devmm_svm \
--device /dev/hisi_hdc \
-v /usr/local/dcmi:/usr/local/dcmi \
-v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
-v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/ \
-v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
-v /etc/ascend_install.info:/etc/ascend_install.info \
-it  ascendai/cann:latest bash
```



### 进入容器

```bash
docker exec -ti cann_container bash
```



### 安装gcc、g++

```bash
apt update && apt install gcc-11 g++-11 -y

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 10
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 10

// 验证是否安装完成
gcc --version && g++ --version
```



### 安装Cmake

```bash
// 安装必要依赖
apt-get install -y  make wget git zlib1g zlib1g-dev openssl libsqlite3-dev libssl-dev libffi-dev unzip pciutils net-tools libblas-dev gfortran libblas3

// 下载cmake
mkdir -p /root/devtoolsets/cmake && cd /root/devtoolsets/cmake
wget https://cmake.org/files/v3.29/cmake-3.29.7.tar.gz

// 解压编译安装 cmake
tar -zxvf cmake-3.29.7.tar.gz && cd cmake-3.29.7 && ./bootstrap
make -j4 && make install
```



### 编译安装ONNXRuntime

```bash
// 安装ONNXRuntime编译必要依赖
pip install packaging wheel

// 拉取克隆项目
cd /root && git clone https://github.com/microsoft/onnxruntime.git && cd onnxruntime

// 设置cann环境变量
source /usr/local/Ascend/ascend-toolkit/set_env.sh 

// 编译运行
./build.sh --allow_running_as_root --config RelWithDebInfo --build_shared_lib --parallel --use_cann --build_wheel --skip_tests

// 构建好的wheel包在 onnxruntime/build/Linux/dist路径下
// 增加可执行权限并安装
chmod +x  xxxx.wheel && pip intstall xxxx.wheel
```

