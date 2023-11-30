#======================================================================================================================
# STAGE 0: get build information and download Nushell
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Debian: 12.2" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.87.1" >> /log

WORKDIR /tmp
RUN \
    # build a URL to download and extract Nushell binaries from a release
    echo "Installing Nushell." && \
    case "${TARGETPLATFORM}" in \
        linux/amd64) ARCH="x86_64" ; COMP="gnu" ;; \
        linux/arm/v7) ARCH="armv7" ; COMP="gnueabihf" ;; \
        linux/arm64) ARCH="aarch64" ; COMP="gnu" ;; \
        *) echo "Unsupported target platform: ${TARGETPLATFORM}." && exit 1 ;; \
    esac && \
    NAME=nu-0.87.1-${ARCH}-unknown-linux-${COMP} && \
    URL=https://github.com/nushell/nushell/releases/download/0.87.1/${NAME}.tar.gz && \
    wget ${URL} && \
    tar -oxzf ${NAME}.tar.gz && \
    mkdir /nu && \
    mv ${NAME}/nu /nu && \
    mkdir /nu-config && \
    mv ${NAME}/LICENSE ${NAME}/README.txt /nu-config && \
    mkdir /nu-plugins && \
    mv ${NAME}/nu_plugin* /nu-plugins

ADD https://raw.githubusercontent.com/bfren/nushell/main/0.87.1/config.nu /nu-config/config.nu
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.87.1/env.nu /nu-config/env.nu


#======================================================================================================================
# STAGE 1: move Nushell files into their correct locations
#======================================================================================================================

FROM scratch as nushell
COPY --from=build /nu/ /usr/bin/
COPY --from=build /nu-config/ /root/.config/nushell/
COPY --from=build /nu-plugins/ /root/.config/nushell/plugins/


#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-debian12.2 AS busybox-executable


#======================================================================================================================
# STAGE 3: install busybox
#======================================================================================================================

FROM debian:12.2-slim AS busybox
COPY --from=busybox-executable / /bin

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
    busybox --install


#======================================================================================================================
# STAGE 4: get overlay from Alpine image
#======================================================================================================================

FROM alpine AS alpine

WORKDIR /tmp
RUN \
    # get the overlay from the Alpine base image
    echo "Cloning Alpine overlay." && \
    apk add git && git clone --branch v2.0.5 https://github.com/bfren/docker-alpine.git && \
    mv docker-alpine/overlay /


#======================================================================================================================
# STAGE 5: install bfren platform
#======================================================================================================================

FROM debian:12.2-slim as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=alpine /overlay /
COPY --from=busybox / /
COPY --from=nushell / /

ARG BF_IMAGE
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
    NUSHELL_VERSION=0.87.1

RUN \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 6: create final image
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
