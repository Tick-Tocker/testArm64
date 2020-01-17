#!/bin/bash -ex

if [ "$(uname -m)" == "aarch64" ]; then
  echo "this is aarch64 platform"
else
  echo "this is amd64 functions"
fi

