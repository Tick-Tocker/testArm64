#!/bin/bash
set -ex

DOCKERHUB_USERNAME="iecedge"
DOCKERHUB_PASSWORD="iecedgeclouddocker"
LINUX_DISTRO="ubuntu"
CONTAINER_SHA="18.04"
IMAGE_ARCH=("amd64" "arm64")

pullImage(){
  docker pull arm64v8/ubuntu:18.04
  docker pull ubuntu:18.04
  # docker tag arm64v8/ubuntu:18.04 iecedge/tempt
  docker tag arm64v8/ubuntu:18.04 iecedge/ubuntu:18.04-arm64
  docker tag ubuntu:18.04 iecedge/ubuntu:18.04-amd64
}


# Enable docker experimental
export DOCKER_CLI_EXPERIMENTAL=enabled

pullImage

    docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_PASSWORD"

    for arch in "${IMAGE_ARCH[@]}"
    do
        docker push iecedge/${LINUX_DISTRO}:${CONTAINER_SHA}-${arch}
    done

    docker manifest create --amend iecedge/${LINUX_DISTRO}:${CONTAINER_SHA} \
            iecedge/${LINUX_DISTRO}:${CONTAINER_SHA}-arm64 \
            iecedge/${LINUX_DISTRO}:${CONTAINER_SHA}-amd64

    for arch in "${IMAGE_ARCH[@]}"
    do
        docker manifest annotate iecedge/${LINUX_DISTRO}:${CONTAINER_SHA} \
                iecedge/${LINUX_DISTRO}:${CONTAINER_SHA}-${arch} \
                --os linux --arch ${arch}
    done

    docker manifest push iecedge/${LINUX_DISTRO}:${CONTAINER_SHA}
