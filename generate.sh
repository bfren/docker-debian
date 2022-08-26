#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

DEBIAN_VERSIONS="10 11 12 sid"
for V in ${DEBIAN_VERSIONS} ; do

    echo "Debian ${V}"
    DEBIAN_MINOR=`cat ./${V}/DEBIAN_MINOR`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        DEBIAN_VERSION=${V} \
        DEBIAN_MINOR=${DEBIAN_MINOR}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

docker system prune -f
echo "Done."
