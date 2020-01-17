#!/bin/bash

LINUX_DISTRO="ubuntu"
IMAGE_NAME=test-build-"${LINUX_DISTRO}"

docker build -f docker/Dockerfile -t ${IMAGE_NAME}:latest ./docker
