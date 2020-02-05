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

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/microsoft-prod.list
sudo apt-get update
sudo apt-get install -y moby-engine moby-cli



ls /etc/docker/
cat /etc/docker/daemon.json

echo $'{\n    "experimental": true\n}' | tee -a /etc/docker/daemon.json
service docker restart

docker manifest --help
echo 999999999999999999999

docker manifest create --amend xxxxx
echo 99999999999999999999999999999999
