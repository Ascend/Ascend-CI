ARG ARCH="aarch64"
FROM quay.io/pypa/manylinux_2_28_${ARCH}:latest

# ARG Definition
ARG ARCH
ARG PYTHON_VERSION
ENV PYTHON_PATH=/opt/python/cp${PYTHON_VERSION}-cp${PYTHON_VERSION}

#
RUN dnf install -y vim wget openssl-devel

# Python
RUN ln -s ${PYTHON_PATH}/bin/python3 /usr/local/bin/python3 && \
    ln -s ${PYTHON_PATH}/bin/python3 /usr/local/bin/python && \
    ln -s ${PYTHON_PATH}/bin/pip3 /usr/local/bin/pip3 && \
    ln -s ${PYTHON_PATH}/bin/pip /usr/local/bin/pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple twine numpy==1.24.0 decorator attrs


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

RUN wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.1.RC1/Ascend-cann-toolkit_8.1.RC1_linux-${ARCH}.run && \
    chmod +x ./Ascend-cann-toolkit_8.1.RC1_linux-${ARCH}.run && \
    ./Ascend-cann-toolkit_8.1.RC1_linux-${ARCH}.run --full -q

RUN echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc && \
    echo "alias ll='ls -l --color=auto'" >> ~/.bashrc