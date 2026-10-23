#======================================================================================================================
# STAGE 0: store build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} quay.io/bfren/alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Debian: 12.15" >> /log && \
    echo "Busybox: 1.37.0" >> /log && \
    echo "Nushell: 0.116.1" >> /log


#======================================================================================================================
# STAGE 1: load busybox
#======================================================================================================================

FROM quay.io/bfren-bin/busybox:1.37.0-261022 AS busybox


#======================================================================================================================
# STAGE 2: load nushell
#======================================================================================================================

FROM quay.io/bfren-bin/nushell:0.116.1-bookworm-261014 AS nushell


#======================================================================================================================
# STAGE 3: load figlet
#======================================================================================================================

FROM quay.io/bfren-bin/figlet:2.2.5-261022 AS figlet


#======================================================================================================================
# STAGE 4: get overlay from Alpine image
#======================================================================================================================

FROM quay.io/bfren/alpine AS alpine

WORKDIR /tmp
RUN \
    # get the overlay from the Alpine base image
    echo "Cloning Alpine overlay." && \
    apk add git && git clone --branch v3.5.2 https://github.com/bfren/docker-alpine.git && \
    mv docker-alpine/overlay /


#======================================================================================================================
# STAGE 5: install bfren platform
#======================================================================================================================

FROM debian:12.15-slim AS install
COPY --from=build /log /etc/bf/BUILD
COPY --from=alpine /overlay /
COPY --from=busybox / /bin
COPY --from=nushell / /
COPY --from=figlet / /
# CA certificate bundle (used by Nushell for HTTPS) - copied from Alpine rather than installing ca-certificates,
# which pulls in openssl and runs update-ca-certificates over every certificate (very slow under QEMU)
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

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
    BF_UPGRADE_PACKAGES=1 \
    # Nushell version string to check against installed verion after installation
    NU_VERSION=0.116.1

RUN \
    # delete all binaries that will be replaced by busybox - those in ${IGNORE} keep their Debian (GNU) versions, e.g.:
    #   dpkg dpkg-deb tar   - dpkg unpacks packages using GNU tar options (e.g. --warning=no-timestamp)
    # applets are matched as whole words (grep -w), so only the ones named here are kept
    echo "Installing busybox." && \
    X=$(busybox --list-full) ; \
    IGNORE="[ [[ addgroup adduser arch cmp date dd dpkg dpkg-deb df du find grep logger mkdir realpath setarch tar" ; \
    for A in ${X} ; do \
        case " ${IGNORE} " in *" ${A##*/} "*) continue ;; esac ; \
        busybox rm -f /${A} ; \
    done ; \
    # install busybox
    busybox --install && \
    # reset /tmp permissions
    chmod 1777 /tmp && \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 6: create final image
#======================================================================================================================

FROM scratch AS final
COPY --from=install / /

LABEL org.opencontainers.image.description="Debian Linux with Busybox and Nushell installed."
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
