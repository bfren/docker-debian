#!/bin/bash

IMAGE=`cat VERSION`
DEBIAN=${1:-12}

docker buildx build \
    --build-arg BF_IMAGE=debian \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${DEBIAN}/Dockerfile \
    -t debian${DEBIAN}-dev \
    . \
    && \
    docker run -it debian${DEBIAN}-dev sh
