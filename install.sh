#!/bin/bash -ex

if [ "$(uname -m)" == "aarch64" ]; then
  echo "this is aarch64 platform"
else
  echo "this is amd64 functions"
fi
export DOCKER_CLI_EXPERIMENTAL=enabled
docker version
docker manifest --help


cat /etc/docker/daemon.json

echo $'{\n    "experimental": true\n}' | tee /etc/docker/daemon.json
service docker restart

docker manifest --help
echo 999999999999999999999
