#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_BRANCH="v2.6.0"
BUSYBOX_VERSION="1.36.1"
BUSYBOX_BUILD="240913"
NUSHELL_VERSION="0.97.1"
DEBIAN_VERSIONS="11 12"

for V in ${DEBIAN_VERSIONS} ; do

    echo "Debian ${V}"
    DEBIAN_MINOR=`cat ./${V}/DEBIAN_MINOR`
    DEBIAN_NAME=`cat ./${V}/DEBIAN_NAME`
    BUSYBOX_IMAGE="${BUSYBOX_VERSION}-debian${DEBIAN_MINOR}-${BUSYBOX_BUILD}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_BRANCH=${ALPINE_BRANCH} \
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        BUSYBOX_VERSION=${BUSYBOX_VERSION} \
        DEBIAN_MINOR=${DEBIAN_MINOR} \
        DEBIAN_NAME=${DEBIAN_NAME} \
        NUSHELL_VERSION=${NUSHELL_VERSION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
