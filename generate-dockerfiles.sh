#!/bin/bash

set -euo pipefail

docker pull quay.io/bfren/alpine

# txiki.js alpine overlay - a branch until the first txiki.js alpine release is tagged
ALPINE_BRANCH="tjs"
BUSYBOX_VERSION="1.37.0"
BUSYBOX_BUILD="261022"
FIGLET_VERSION="2.2.5"
FIGLET_BUILD="261022"
TJS_VERSION="26.11.0"
TJS_BUILD="261101"
DEBIAN_VERSIONS="12 13"

for V in ${DEBIAN_VERSIONS} ; do

    echo "Debian ${V}"
    DEBIAN_MINOR=`cat ./${V}/DEBIAN_MINOR`
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    BUSYBOX_IMAGE="${BUSYBOX_VERSION}-${BUSYBOX_BUILD}"
    FIGLET_IMAGE="${FIGLET_VERSION}-${FIGLET_BUILD}"
    TJS_IMAGE="${TJS_VERSION}-${TJS_BUILD}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_BRANCH=${ALPINE_BRANCH} \
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        BUSYBOX_VERSION=${BUSYBOX_VERSION} \
        FIGLET_IMAGE=${FIGLET_IMAGE} \
        FIGLET_VERSION=${FIGLET_VERSION} \
        DEBIAN_MAJOR=${V} \
        DEBIAN_MINOR=${DEBIAN_MINOR} \
        DEBIAN_NAME=${DEBIAN_NAME} \
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        TJS_IMAGE=${TJS_IMAGE} \
        TJS_VERSION=${TJS_VERSION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
