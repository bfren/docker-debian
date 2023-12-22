#!/bin/bash

set -euo pipefail

DEBIAN_EDITIONS="11 12 13"
for E in ${DEBIAN_EDITIONS} ; do

    echo "Building Debian ${E}."
    docker buildx build \
        --load \
        --quiet \
        --build-arg BF_IMAGE=debian \
        --build-arg BF_VERSION=0.1.0 \
        -f ${E}/Dockerfile \
        -t debian${E}-test \
        .

    echo "Running tests."
    docker run \
        -e BF_TESTING=1 \
        debian${E}-test env -i nu -c "use nupm test ; test --dir /etc/nu/scripts/bf"

    echo ""

done
