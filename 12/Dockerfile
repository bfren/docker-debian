#======================================================================================================================
# STAGE 0: get build information and download Nushell
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Debian: 12.7" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.98.0" >> /log

WORKDIR /tmp
RUN \
    # build a URL to download Nushell
    echo "Building Nushell download URL." && \
    case "${TARGETPLATFORM}" in \
        "linux/amd64") ARCH="x86_64" && CLIB="gnu" ;; \
        "linux/arm/v7") ARCH="armv7" && CLIB="gnueabihf" ;; \
        "linux/arm64") ARCH="aarch64" && CLIB="gnu" ;; \
        *) echo "Unsupported target platform: ${TARGETPLATFORM}." && exit 1 ;; \
    esac && \
    RELEASES=https://github.com/nushell/nushell/releases/download/0.98.0 && \
    FILE=nu-0.98.0-${ARCH}-unknown-linux-${CLIB} && \
    EXT=tar.gz && \
    URL=${RELEASES}/${FILE}.${EXT} && \
    # build a URL to download Nushell
    echo "Downloading Nushell from ${URL}." && \
    wget ${URL} && \
    # extract Nushell and move it to root
    echo "Extracting Nushell." && \
    tar -xf ${FILE}.${EXT} && \
    mv ${FILE}/ /nu


#======================================================================================================================
# STAGE 1: create blank image containing Nushell executable, plugins and config in the correct locations
#======================================================================================================================

FROM scratch AS nushell
COPY --from=build /nu/nu /usr/bin/
COPY --from=build /nu/nu_plugin* /etc/nu/plugins/
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.98.0/config.nu /etc/nu/config.nu
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.98.0/env.nu /etc/nu/env.nu


#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-debian12.7-240913 AS busybox


#======================================================================================================================
# STAGE 3: get overlay from Alpine image
#======================================================================================================================

FROM ghcr.io/bfren/alpine AS alpine

WORKDIR /tmp
RUN \
    # get the overlay from the Alpine base image
    echo "Cloning Alpine overlay." && \
    apk add git && git clone --branch v2.6.0 https://github.com/bfren/docker-alpine.git && \
    mv docker-alpine/overlay /


#======================================================================================================================
# STAGE 4: install bfren platform
#======================================================================================================================

FROM debian:12.7-slim AS install
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
    NU_VERSION=0.98.0

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
    # reset /tmp permissions
    chmod 1777 /tmp && \
    # add packages required by Nushell
    apt update && apt install --no-install-recommends -y libgit2-dev openssl sqlite3 && \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 5: create final image
#======================================================================================================================

FROM scratch AS final
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
