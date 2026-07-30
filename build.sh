#!/bin/bash
set -e

IMAGE_NAME="${IMAGE_NAME:-ninjadesktop-lite}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

docker buildx build \
  --platform "${PLATFORMS}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  --output type=docker \
  .
