#======================================================================================================================
# STAGE 0: get build information and download Nushell
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Debian: 11.8" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.86.0" >> /log

WORKDIR /tmp
RUN case "${TARGETPLATFORM}" in \
        linux/amd64) ARCH="x86_64" ; COMP="gnu" ;; \
        linux/arm/v7) ARCH="armhf" ; COMP="gnueabihf" ;; \
        linux/arm64) ARCH="aarch64" ; COMP="gnu" ;; \
        *) echo "Unsupported target platform: ${TARGETPLATFORM}." && exit 1 ;; \
    esac && \
    NAME=nu-0.86.0-${ARCH}-unknown-linux-${COMP} && \
    URL=https://github.com/nushell/nushell/releases/download/0.86.0/${NAME}.tar.gz && \
    echo "Downloading ${URL}..." && \
    wget ${URL} && \
    tar -oxzf ${NAME}.tar.gz && \
    echo "Moving files to /nu folders..." && \
    mkdir /nu && \
    mv ${NAME}/nu /nu && \
    mkdir /nu-config && \
    mv ${NAME}/LICENSE ${NAME}/README.txt /nu-config && \
    mkdir /nu-plugins && \
    mv ${NAME}/nu_plugin* /nu-plugins

ADD https://raw.githubusercontent.com/bfren/nushell/main/0.86.0/config.nu /nu-config/config.nu
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.86.0/env.nu /nu-config/env.nu


#======================================================================================================================
# STAGE 1: move Nushell files into their correct locations
#======================================================================================================================

FROM scratch as nushell
COPY --from=build /nu/ /usr/bin/
COPY --from=build /nu-config/ /root/.config/nushell/
COPY --from=build /nu-plugins/ /root/.config/nushell/plugins/


#======================================================================================================================
# STAGE 2: load Busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-debian11.8 AS busybox-executable


#======================================================================================================================
# STAGE 3: install busybox
#======================================================================================================================

FROM debian:11.8-slim AS busybox
COPY --from=busybox-executable / /bin

RUN echo "Removing executables that will be replaced by busybox..." ; \
    X=$(busybox --list-full) ; \
    IGNORE="[ [[ addgroup adduser cmp dpkg dpkg-deb df find grep logger mkdir setarch" ; \
    for A in ${X} ; do \
    if busybox printf "%s\0" "${IGNORE}" | busybox grep -q `busybox basename ${A}` ; then continue ; \
    else busybox echo " .. /${A}" && busybox rm -f /${A} ; \
    fi ; \
    done ; \
    echo "Installing busybox..." ; \
    busybox --install ; \
    echo "Build complete."


#======================================================================================================================
# STAGE 4: load Alpine base image
#======================================================================================================================

FROM bfren/alpine:dev AS alpine


#======================================================================================================================
# STAGE 5: install bfren platform
#======================================================================================================================

FROM debian:11.8-slim as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=alpine /init /init
COPY --from=alpine /etc/nu/ /etc/nu/
COPY --from=alpine /usr/bin/bf/ /usr/bin/bf/
COPY --from=busybox / /
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_VERSION

ENV BF_ETC=/etc/bf \
    BF_UPGRADE_PACKAGES=0 \
    NUSHELL_VERSION=0.86.0

COPY ./overlay /

RUN chmod +x /preinstall && /preinstall
RUN /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 6: create final image
#======================================================================================================================

FROM scratch as final
COPY --from=install / /

LABEL org.opencontainers.image.description="Debian base image with Busybox and Nushell."
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
