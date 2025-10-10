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

LATEST_TAG=$1
echo "New tag (from github): $LATEST_TAG"

REPO="microsoft/onnxruntime"
REPO_URL="https://github.com/$REPO.git"
MAX_RETRIES=10
WAIT_SECONDS=60

build_and_upload() {
  local TAG="$1"
  local CLONE_SUCCESS=0

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
  git config --global user.name "dou"
  git config --global user.email "15529241576@163.com"
  git fetch "$REPO_URL" pull/25627/head:pr-123
  git cherry-pick pr-123
  
  ./build.sh --allow_running_as_root \
             --config Release \
             --build_shared_lib \
             --parallel \
             --use_cann \
             --build_wheel \
             --skip_tests

    echo "开始上传到 PyPI (onnxruntime-cann)..."
    python3 -m twine upload --non-interactive --skip-existing --repository onnxruntime-cann build/Linux/Release/dist/*.whl
}

echo "================ Cron job started at $(date) ================"

source /usr/local/Ascend/ascend-toolkit/set_env.sh

build_and_upload "$LATEST_TAG"
