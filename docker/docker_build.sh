#!/bin/bash

LINUX_DISTRO="ubuntu"
IMAGE_NAME=test-build-"${LINUX_DISTRO}"

docker build -f Dockerfile-${LINUX_DISTRO} -t ${IMAGE_NAME}:latest .
