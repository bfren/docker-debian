#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BUSYBOX_VERSION="1.36.1"
echo "Busybox: ${BUSYBOX_VERSION}"

DEBIAN_VERSIONS="10 11 12 13"
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
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        DEBIAN_VERSION=${V} \
        DEBIAN_MINOR=${DEBIAN_MINOR}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
