ARG ARCH="aarch64"
ARG PYTHON_VERSION="3.12.3"
FROM quay.io/pypa/manylinux_2_28_${ARCH}:latest

# ARG Definition
ARG ARCH
ARG PYTHON_VERSION
RUN dnf install -y vim wget openssl-devel make libffi-devel bzip2-devel zlib-devel readline-devel sqlite-devel

# Python
WORKDIR /opt
RUN set -eux; \
    PY_SRC="Python-${PYTHON_VERSION}"; \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/${PY_SRC}.tgz && \
    tar -xzf ${PY_SRC}.tgz && \
    cd ${PY_SRC} && \
    ./configure --prefix=/opt/python${PYTHON_VERSION} --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    cd /opt && \
    rm -rf ${PY_SRC} ${PY_SRC}.tgz && \
    PY_MM=$(echo ${PYTHON_VERSION} | cut -d. -f1,2) && \
    ln -sf /opt/python${PYTHON_VERSION}/bin/python${PY_MM} /usr/local/bin/python3 && \
    ln -sf /opt/python${PYTHON_VERSION}/bin/python${PY_MM} /usr/local/bin/python && \
    ln -sf /opt/python${PYTHON_VERSION}/bin/pip${PY_MM} /usr/local/bin/pip3 && \
    ln -sf /opt/python${PYTHON_VERSION}/bin/pip${PY_MM} /usr/local/bin/pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple \
    setuptools \
    twine \
    packaging \
    wheel \
    numpy==1.26.4 \
    decorator \
    attrs \
    flatbuffers \
    protobuf==4.25.3

RUN cd /opt && \
    wget https://cmake.org/files/v3.29/cmake-3.29.7.tar.gz && \
    mkdir cmake && \
    tar -zxvf cmake-3.29.7.tar.gz -C /opt/cmake --strip-components=1 && \
    cd cmake && \
    ./bootstrap && \
    make -j$(nproc) && \
    make install

ENV PATH="/opt/cmake/bin:${PATH}"

WORKDIR /root
	
RUN wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run && \
    chmod +x ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run && \
    ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run --full -q && \
    rm ./Ascend-cann-toolkit_8.5.0_linux-${ARCH}.run

RUN echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc && \
    echo "alias ll='ls -l --color=auto'" >> ~/.bashrc