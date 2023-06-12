FROM ghcr.io/bfren/busybox:1.36.1-debianbookworm AS busybox

FROM debian:bookworm-slim AS build
COPY --from=busybox / /bin

RUN echo "Removing executables that will be replaced by busybox..." ; \
    X=$(busybox --list-full) ; \
    IGNORE="[ [[ cmp dpkg dpkg-deb df find grep logger mkdir setarch" ; \
    for A in ${X} ; do \
    if busybox printf "%s\0" "${IGNORE}" | busybox grep -q `busybox basename ${A}` ; then continue ; \
    else busybox echo " .. /${A}" && busybox rm -f /${A} ; \
    fi ; \
    done ; \
    echo "Installing busybox..." ; \
    busybox --install ; \
    echo "Build complete."

FROM scratch AS final
COPY --from=build / /

LABEL org.opencontainers.image.description="Debian base image with BusyBox preinstalled and various custom executables."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-debian"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # Debian version
    DEBIAN_MINOR=bookworm \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # path to bf executables
    BF_BIN=/usr/bin/bf \
    # path to bf library executables
    BF_LIB=/usr/lib/bf

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./12/overlay /

RUN chmod +x ${BF_BIN}/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
