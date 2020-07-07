#!/bin/bash

# Do not ever set -x here, it is a security hazard as it will place the credentials below in the
# CI logs.
set -ex

# Setting environments for buildx tools
config_env(){
    # Qemu configurations
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

    # Remove older build instance
    docker buildx rm  multi-builder | true
    docker buildx create --use --name multi-builder --platform linux/arm64,linux/amd64
}

# Build image
# $1 Build types ("" "-alpine" "-alpine-debug" "-google-vrp")
# $2 Dockerfile
# $3 image tag
<<COMMENTS
build_images(){
    BUILD_TYPE=$1
    DOCKERFILE=$2
    IMAGETAG=$3
    PUSH=$4

    if [ -z "${BUILD_TYPE}" ]; then
        # If BUILD_TYPE is empty, build multiarch images
        docker buildx build --platform linux/amd64,linux/arm64 $PUSH -f "${DOCKERFILE}" -t "${IMAGETAG}" .
    else
        # Build x86 images
        docker buildx build $PUSH -f "${DOCKERFILE}" -t "${IMAGETAG}" .
    fi
}
COMMENTS

build_images(){
    BUILD_TYPE=$1
    DOCKERFILE=$2
    IMAGETAG=$3

    if [ -z "${BUILD_TYPE}" ]; then
        # If BUILD_TYPE is empty, build multiarch images
        docker buildx build -o type=docker --platform linux/amd64 -f "${DOCKERFILE}" -t "${IMAGETAG}" .
        docker buildx build -o type=docker --platform linux/arm64 -f "${DOCKERFILE}" -t "${IMAGETAG}"-arm64 .
    else
        # Build x86 images
        docker build -f "${DOCKERFILE}" -t "${IMAGETAG}" .
    fi
}

push_images(){
    BUILD_TYPE=$1
    DOCKERFILE=$2
    IMAGETAG=$3

    if [ -z "${BUILD_TYPE}" ]; then
        # if BUILD_TYPE is empty, push multi-arch images
        docker buildx build --platform linux/amd64,linux/arm64 --push -f "${DOCKERFILE}" -t "${IMAGETAG}" .
    else
        # Push x86 images
        docker push "${IMAGETAG}" .
    fi
}

# This prefix is altered for the private security images on setec builds.
DOCKER_IMAGE_PREFIX="${DOCKER_IMAGE_PREFIX:-iecedge/envoy}"

# "-google-vrp" must come afer "" to ensure we rebuild the local base image dependency.
BUILD_TYPES=("" "-alpine" "-alpine-debug" "-google-vrp")

# Configure docker-buildx tools 
config_env

# Test the docker build in all cases, but use a local tag that we will overwrite before push in the
# cases where we do push.
for BUILD_TYPE in "${BUILD_TYPES[@]}"; do
    build_images "${BUILD_TYPE}" "ci/Dockerfile-envoy${BUILD_TYPE}" "${DOCKER_IMAGE_PREFIX}${BUILD_TYPE}:local"
done

MASTER_BRANCH="refs/heads/master"
RELEASE_BRANCH_REGEX="^refs/heads/release/v.*"
RELEASE_TAG_REGEX="^refs/tags/v.*"

# Only push images for master builds, release branch builds, and tag builds.
if [[ "${AZP_BRANCH}" != "${MASTER_BRANCH}" ]] && \
   ! [[ "${AZP_BRANCH}" =~ ${RELEASE_BRANCH_REGEX} ]] && \
   ! [[ "${AZP_BRANCH}" =~ ${RELEASE_TAG_REGEX} ]]; then
    echo 'Ignoring non-master branch or tag for docker push.'
    exit 0
fi

# For master builds and release branch builds use the dev repo. Otherwise we assume it's a tag and
# we push to the primary repo.
if [[ "${AZP_BRANCH}" == "${MASTER_BRANCH}" ]] || \
   [[ "${AZP_BRANCH}" =~ ${RELEASE_BRANCH_REGEX} ]]; then
  IMAGE_POSTFIX="-dev"
  IMAGE_NAME="$AZP_SHA1"
else
  IMAGE_POSTFIX=""
  IMAGE_NAME="${AZP_BRANCH/refs\/tags\//}"
fi

docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_PASSWORD"

for BUILD_TYPE in "${BUILD_TYPES[@]}"; do

    # The buildx will directly push the multi-arch images to repo since that the image has been cached in local host
    push_images "$BUILD_TYPE" "ci/Dockerfile-envoy${BUILD_TYPE}" "${DOCKER_IMAGE_PREFIX}${BUILD_TYPE}${IMAGE_POSTFIX}:${IMAGE_NAME}"

    # Only push latest on master builds.
    if [[ "${AZP_BRANCH}" == "${MASTER_BRANCH}" ]]; then
        push_images "$BUILD_TYPE" ci/Dockerfile-envoy"${BUILD_TYPE}" "${DOCKER_IMAGE_PREFIX}${BUILD_TYPE}${IMAGE_POSTFIX}:latest"
    fi

    # Push vX.Y-latest to tag the latest image in a release line
    if [[ "${AZP_BRANCH}" =~ ${RELEASE_TAG_REGEX} ]]; then
      RELEASE_LINE=$(echo "$IMAGE_NAME" | sed -E 's/(v[0-9]+\.[0-9]+)\.[0-9]+/\1-latest/')
      push_images "$BUILD_TYPE" "ci/Dockerfile-envoy${BUILD_TYPE}" "${DOCKER_IMAGE_PREFIX}${BUILD_TYPE}${IMAGE_POSTFIX}:${RELEASE_LINE}"
    fi
done


