#!/bin/bash

cd $(dirname $0)
docker build \
  --build-arg TARGETARCH=amd64 \
  -t kindest/node:v1.37.0-mount-options .
