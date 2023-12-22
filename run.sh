#!/bin/bash

IMAGE=`cat VERSION`
DEBIAN=${1:-12}

docker buildx build \
    --load \
    --progress plain \
    --build-arg BF_IMAGE=debian \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${DEBIAN}/Dockerfile \
    -t debian${DEBIAN}-dev \
    . \
    && \
    docker run -it -e BF_DEBUG=1 debian${DEBIAN}-dev nu
