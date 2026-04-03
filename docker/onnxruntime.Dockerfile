ARG ARCH="aarch64"
ARG PYTHON_VERSION="312"
FROM quay.io/pypa/manylinux_2_28_${ARCH}:latest

# ARG Definition
ARG ARCH
ARG PYTHON_VERSION
ENV PYTHON_PATH=/opt/python/cp${PYTHON_VERSION}-cp${PYTHON_VERSION}

# System dependencies
RUN dnf install -y \
        vim wget git \
        openssl-devel \
        patchelf \
        zlib-devel bzip2-devel \
        tar unzip make \
    && dnf clean all && rm -rf /var/cache/dnf

# Python symlinks
RUN ln -s ${PYTHON_PATH}/bin/python3 /usr/local/bin/python3 && \
    ln -s ${PYTHON_PATH}/bin/python3 /usr/local/bin/python && \
    ln -s ${PYTHON_PATH}/bin/pip3 /usr/local/bin/pip3 && \
    ln -s ${PYTHON_PATH}/bin/pip /usr/local/bin/pip

# Python packages: build tools + onnxruntime build requirements
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple \
        twine \
        auditwheel \
        ninja \
        numpy \
        decorator attrs \
        pytest \
        "setuptools>=68.2.2" wheel \
        protobuf \
        sympy \
        flatbuffers \
        psutil \
        onnx \
        onnxscript \
        onnx-ir \
        jinja2 markupsafe

# CMake (source build, manylinux ships an old version)
RUN cd /opt && \
    wget https://cmake.org/files/v3.29/cmake-3.29.7.tar.gz && \
    mkdir cmake && \
    tar -zxvf cmake-3.29.7.tar.gz -C /opt/cmake --strip-components=1 && \
    cd cmake && \
    ./bootstrap && \
    make -j$(nproc) && \
    make install && \
    cd /opt && rm -rf cmake cmake-3.29.7.tar.gz

# Ascend CANN Toolkit
WORKDIR /root

RUN wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run && \
    chmod +x ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run && \
    ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run --full -q && \
    rm -f ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run

# ASCEND_HOME_PATH must be ENV: build.py reads it via os.getenv() when --cann_home is not passed.
# Other PATH/LD_LIBRARY_PATH: use "source set_env.sh &&" in the same RUN as the build command.
ENV ASCEND_HOME_PATH=/usr/local/Ascend/cann/latest

RUN echo "alias ll='ls -l --color=auto'" >> ~/.bashrc

CMD ["/bin/bash"]
