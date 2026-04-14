#!/bin/bash
set -e

IMAGE_REPO="swr.cn-south-1.myhuaweicloud.com/onnx-repo/manylinux_2_28_x86_64"
IMAGE_TAG="${1:-$(git rev-parse --short HEAD)}"
NO_PUSH="${2:-}"

if [ "${NO_PUSH}" = "--no-push" ]; then
  OUTPUT="type=docker"
else
  OUTPUT="type=image,push=true,oci-mediatypes=false"
fi

docker buildx build \
  --build-arg ARCH=x86_64 \
  -t "${IMAGE_REPO}:${IMAGE_TAG}" \
  -t "${IMAGE_REPO}:latest" \
  -f docker/onnxruntime.Dockerfile \
  --output "${OUTPUT}" .

echo "Done: ${IMAGE_REPO}:${IMAGE_TAG} / ${IMAGE_REPO}:latest"
