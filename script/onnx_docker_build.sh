#!/bin/bash
set -e

IMAGE_REPO="swr.cn-southwest-2.myhuaweicloud.com/onnxruntime_image/manylinux_2_28"
ARCH="aarch64"
IMAGE_TAG=""
NO_PUSH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --arch)    ARCH="$2";      shift 2 ;;
    --tag)     IMAGE_TAG="$2"; shift 2 ;;
    --no-push) NO_PUSH=true;   shift   ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short HEAD)}"

if [ "${NO_PUSH}" = true ]; then
  OUTPUT="type=docker"
else
  OUTPUT="type=image,push=true,oci-mediatypes=false"
fi
docker buildx build \
  --build-arg ARCH=${ARCH} \
  -t "${IMAGE_REPO}:${ARCH}-${IMAGE_TAG}" \
  -t "${IMAGE_REPO}:latest" \
  -f docker/onnxruntime.Dockerfile \
  --output "${OUTPUT}" .

echo "Done: ${IMAGE_REPO}:${IMAGE_TAG} / ${IMAGE_REPO}:latest"
