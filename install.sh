#!/bin/bash -x

if [ "$(uname -m)" == "aarch64" ]; then
  echo "this is aarch64 platform"
else
  echo "this is amd64 functions"
fi

export DOCKER_CLI_EXPERIMENTAL=enabled
docker version
docker manifest --help

echo 111111111111111111111111111111111111111111

docker manifest create --help
echo 99999999999999999999999999999999
source docker_push.sh
