#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_BRANCH="v2.9.5"
BUSYBOX_VERSION="1.36.1"
BUSYBOX_BUILD="250606"
NU_VERSION="0.105.1"
NU_BUILD="250606"
DEBIAN_VERSIONS="12"

for V in ${DEBIAN_VERSIONS} ; do

    echo "Debian ${V}"
    DEBIAN_MINOR=`cat ./${V}/DEBIAN_MINOR`
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    BUSYBOX_IMAGE="${BUSYBOX_VERSION}-debian${DEBIAN_MINOR}-${BUSYBOX_BUILD}"
    NU_IMAGE="${NU_VERSION}-${DEBIAN_NAME}-${NU_BUILD}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_BRANCH=${ALPINE_BRANCH} \
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        BUSYBOX_VERSION=${BUSYBOX_VERSION} \
        DEBIAN_MAJOR=${V} \
        DEBIAN_MINOR=${DEBIAN_MINOR} \
        DEBIAN_NAME=${DEBIAN_NAME} \
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        NU_IMAGE=${NU_IMAGE} \
        NU_VERSION=${NU_VERSION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
