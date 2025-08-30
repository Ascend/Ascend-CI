# ==============================================================================
# ARGUMENTS
# ==============================================================================

# Define the CANN base image for easier version updates later
ARG CANN_BASE_IMAGE=quay.io/ascend/cann:8.2.rc1-910b-ubuntu22.04-py3.11

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_ROOT_USER_ACTION=ignore

RUN pip install --upgrade pip setuptools wheel --trusted-host mirrors.aliyun.com --index-url https://mirrors.aliyun.com/pypi/simple/

RUN pip uninstall -y torch torchvision torch-tensorrt \
    flash_attn transformer-engine \
    cudf dask-cuda cugraph cugraph-service-server cuml raft-dask cugraph-dgl cugraph-pyg dask-cudf

RUN pip install torch==2.7.1 torch==2.7.1rc1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    { \
    echo "deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse"; \
    echo "deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse"; \
    echo "deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse"; \
    echo "deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse"; \
    } > /etc/apt/sources.list

RUN apt-get update && apt-get install -y openjdk-11-jdk 
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

RUN pip uninstall -y opencv opencv-python opencv-python-headless && \
    rm -rf /usr/local/lib/python3.10/dist-packages/cv2/ && \
    pip install opencv-python-headless==4.11.0.86 --trusted-host mirrors.aliyun.com --index-url https://mirrors.aliyun.com/pypi/simple/

RUN pip install "numpy==1.26.4" "optree>=0.13.0" "spacy==3.7.5" "weasel==0.4.1" \
    transformer-engine[pytorch]==2.2.0 megatron-core==0.11.0 deepspeed==0.16.4 \
    --trusted-host mirrors.aliyun.com --index-url https://mirrors.aliyun.com/pypi/simple/

RUN pip install https://github.com/Dao-AILab/flash-attention/releases/download/v2.7.2.post1/flash_attn-2.7.2.post1+cu12torch2.6cxx11abiFALSE-cp310-cp310-linux_x86_64.whl

RUN pip install vllm==0.10.0 \
    --trusted-host mirrors.aliyun.com --index-url https://mirrors.aliyun.com/pypi/simple/

WORKDIR /build
COPY . .

ARG apex_url=git+https://github.com/NVIDIA/apex.git@25.04
RUN pip uninstall -y apex && \
    MAX_JOBS=32 NINJA_FLAGS="-j32" NVCC_APPEND_FLAGS="--threads 32" \
    pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation \
    --config-settings "--build-option=--cpp_ext --cuda_ext --parallel 32" ${apex_url}

RUN rm -rf *
WORKDIR /workspace

RUN apt-get install -y zip