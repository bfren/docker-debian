#======================================================================================================================
# STAGE 0: get build information and download Nushell
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Debian: 11.9" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.94.2" >> /log


#======================================================================================================================
# STAGE 1: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.94.2-bullseye as nushell


#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-debian11.9 AS busybox


#======================================================================================================================
# STAGE 3: get overlay from Alpine image
#======================================================================================================================

FROM alpine AS alpine

WORKDIR /tmp
RUN \
    # get the overlay from the Alpine base image
    echo "Cloning Alpine overlay." && \
    apk add git && git clone --branch v2.4.1 https://github.com/bfren/docker-alpine.git && \
    mv docker-alpine/overlay /


#======================================================================================================================
# STAGE 4: install bfren platform
#======================================================================================================================

FROM debian:11.9-slim as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=alpine /overlay /
COPY --from=busybox / /bin
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

COPY ./overlay /

ENV \
    # path to bf configuration - installation script requires this
    BF_ETC=/etc/bf \
    # set container to this timezone
    BF_TZ=Europe/London \
    # whether or not to upgrade packages during installation
    #   0: no
    #   1: yes
    BF_UPGRADE_PACKAGES=0 \
    # Nushell version string to check against installed verion after installation
    NUSHELL_VERSION=0.94.2

RUN \
    # delete all binaries that will be replaced by busybox - those in ${IGNORE} will be left alone
    echo "Installing busybox." && \
    X=$(busybox --list-full) ; \
    IGNORE="[ [[ addgroup adduser cmp dpkg dpkg-deb df find grep logger mkdir setarch" ; \
    for A in ${X} ; do \
    if busybox printf "%s\0" "${IGNORE}" | busybox grep -q -F `busybox basename ${A}` ; then continue ; \
    else busybox rm -f /${A} ; \
    fi ; \
    done ; \
    # install busybox
    busybox --install && \
    # add packages required by Nushell
    apt update && apt install --no-install-recommends -y ca-certificates libgit2-dev openssl sqlite3 && \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 5: create final image
#======================================================================================================================

FROM scratch as final
COPY --from=install / /

LABEL org.opencontainers.image.description="Debian Linux with default Busybox and Nushell installed."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-debian"

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # path to bfren configuration directory
    BF_ETC=/etc/bf \
    # add bfren executables to PATH
    PATH=/usr/bin/bf:${PATH}

ENTRYPOINT [ "/init" ]
