#!/bin/bash

set -e
cat > ~/.pypirc <<EOF
[distutils]
index-servers = onnxruntime-cann
[onnxruntime-cann]
repository = https://upload.pypi.org/legacy/
username = __token__
password = $PYPI_TOKEN
EOF

build_and_upload() {
  local TAG="$1"
  local CLONE_SUCCESS=0
  rm -rf onnxruntime

  for i in $(seq 1 "$MAX_RETRIES"); do
    echo " 第 $i 次尝试 clone..."

    git clone --branch "$TAG" \
              --depth 1 "$REPO_URL" \
              onnxruntime && CLONE_SUCCESS=1 && break

    echo "第 $i 次 clone 失败，等待 $WAIT_SECONDS 秒后重试..."
    sleep "$WAIT_SECONDS"
  done

  if [ "$CLONE_SUCCESS" -ne 1 ]; then
    echo "连续 $MAX_RETRIES 次 git clone 失败，退出。"
    exit 1
  fi

  cd onnxruntime

  ./build.sh --allow_running_as_root \
             --config Release \
             --build_shared_lib \
             --parallel \
             --use_cann \
             --build_wheel \
             --skip_tests

    echo "开始上传到 PyPI (onnxruntime-cann)..."
    python3 -m twine upload --repository onnxruntime-cann build/Linux/Release/dist/*.whl
}

echo "================ Cron job started at $(date) ================"

# 切换到脚本所在目录执行
REPO="microsoft/onnxruntime"
API="https://api.github.com/repos/$REPO/tags"
REPO_URL="https://github.com/$REPO.git"
STATE_FILE="/root/.last_tag"
MAX_RETRIES=10
WAIT_SECONDS=60

source /usr/local/Ascend/ascend-toolkit/set_env.sh

# 获取最新 tag
LATEST_TAG=$(curl -s --connect-timeout 15 --max-time 30 "$API" | grep '"name":' | head -n 1 | cut -d '"' -f 4)

LAST_TAG=""
# 获取之前已上传的 tag
if [ -s "$STATE_FILE" ]; then
    LAST_TAG=$(cat "$STATE_FILE")
fi

if [ "$LATEST_TAG" != "$LAST_TAG" ]; then
    echo "Detected new tag: $LATEST_TAG"
    build_and_upload "$LATEST_TAG"
    echo "$LATEST_TAG" > "$STATE_FILE"
else
    echo "No new tag. Latest is still: $LATEST_TAG"
fi
