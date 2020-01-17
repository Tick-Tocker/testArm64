#!/bin/bash -ex

if [ "$(uname -m)" == "aarch64" ]; then
  echo "this is aarch64 platform"
  source ../docker/docker_build.sh
else
  echo "this is amd64 functions"
  source ../docker/docker_build.sh
fi

