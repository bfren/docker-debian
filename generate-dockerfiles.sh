#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_BRANCH="v2.0.5"
BUSYBOX_VERSION="1.36.1"
NUSHELL_VERSION="0.87.1"
DEBIAN_VERSIONS="11 12 13"

for V in ${DEBIAN_VERSIONS} ; do

    echo "Debian ${V}"
    DEBIAN_MINOR=`cat ./${V}/DEBIAN_MINOR`

    if [ "${DEBIAN_MINOR}" = "12.0" ] ; then
        BUSYBOX_IMAGE="${BUSYBOX_VERSION}-debian12"
    else
        BUSYBOX_IMAGE="${BUSYBOX_VERSION}-debian${DEBIAN_MINOR}"
    fi

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
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        NUSHELL_VERSION=${NUSHELL_VERSION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
