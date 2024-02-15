#!/bin/sh

IMAGE=`cat VERSION`
DEBIAN=${1:-12}

docker buildx build \
    --load \
    --build-arg BF_IMAGE=debian \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${DEBIAN}/Dockerfile \
    -t debian${DEBIAN}-test \
    . \
    && \
    docker run --rm debian${DEBIAN}-test env -i nu -c "use bf test ; test"
