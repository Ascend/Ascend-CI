# Use the official CANN container image with Python 3.11 on Ubuntu 22.04 for Ascend NPU
FROM ascendai/cann:8.1.RC1-910b-ubuntu22.04-py3.10

# Set environment variables: use HF mirror for faster downloads
ENV HF_ENDPOINT=https://hf-mirror.com \
    DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /workspace

# Replace Ubuntu package sources with Tsinghua Mirror for faster downloads
# Install essential system dependencies and libraries
RUN sed -i 's|ports.ubuntu.com|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
    git gcc g++ make cmake ninja-build wget curl\
    libgl1 libglib2.0-0 libsndfile1 libcurl4-openssl-dev unzip \
    # Clean up apt cache to reduce image size
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

# Configure pip to use Tsinghua Mirror for faster Python package installation
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# Install PyTorch (CPU version) and the compatible NPU plugin for Ascend 910B
# Note: Versions are pinned for compatibility with CANN 8.2.RC1
RUN pip install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cpu && \
    pip install torch_npu==2.7.1rc1 && \
    python -c "import torch; print(torch.npu.is_available())"

# Install common deep learning and AI development libraries
RUN pip install transformers==4.52.4 huggingface_hub sentencepiece

# Clone and install vLLM (Version 0.8.4) from source
# VLLM_TARGET_DEVICE=empty is set to avoid device-specific builds at this stage
RUN git clone --depth=1 --branch=v0.10.0 https://github.com/vllm-project/vllm.git && \
    cd vllm && \
    VLLM_TARGET_DEVICE=empty pip install -v -e . && \
    cd .. && \
    rm -rf vllm && \
    python -c "import torch; print(torch.npu.is_available())"

# Clone and install the Ascend backend for vLLM (Version 0.8.4rc2)
# COMPILE_CUSTOM_KERNELS=1 is essential for building NPU-specific kernels
RUN git clone --depth=1 --branch=v0.10.0rc1 https://github.com/vllm-project/vllm-ascend.git && \
    cd vllm-ascend && \
    export COMPILE_CUSTOM_KERNELS=1 && \
    grep -v "torch" requirements.txt > requirements_no_torch.txt && cat requirements_no_torch.txt && \
    pip install -r requirements_no_torch.txt && \
    cd .. && \
    rm -rf vllm-ascend && \
    python -c "import torch; print(torch.npu.is_available())"

# Clone and install the ROLL framework from Alibaba's repository
# Install its common requirements and the specified version of DeepSpeed
RUN git clone --depth=1 https://github.com/alibaba/ROLL.git && \
    cd ROLL && \
    grep -v "sympy|transformers" requirements_common.txt > temp.txt && cat temp.txt && \
    pip install -r temp.txt torch==2.7.1+cpu --extra-index-url https://download.pytorch.org/whl/cpu && \
    pip install deepspeed==0.16.0 && \
    cd .. && \
    python -c "import torch; print(torch.npu.is_available())"

# Set the final working directory
WORKDIR /workspace

# Set HF_ENDPOINT again to ensure it's available in the final environment
ENV HF_ENDPOINT=https://hf-mirror.com

# Default command: Display NPU information and launch a Bash shell
# This helps verify the NPU environment upon container start
CMD ["bash", "-c", "npu-smi info && bash"]
