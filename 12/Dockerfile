FROM debian:bookworm AS busybox

RUN apt update && apt install -y bzip2 gcc make
ADD https://busybox.net/downloads/busybox-1.35.0.tar.bz2 /tmp

WORKDIR /tmp
RUN tar -xf busybox-1.35.0.tar.bz2
RUN cd busybox-1.35.0 ; make defconfig ; make ; make install

FROM debian:bookworm-slim AS build
COPY --from=busybox /tmp/busybox-1.35.0/busybox /bin/

RUN X=$(busybox --list) ; \
    IGNORE="[ [[ cmp dpkg dpkg-deb df find logger mkdir setarch" ; \
    echo "Removing executables and installing busybox..." ; \
    for A in ${X} ; do \
    if printf "%s\0" "${IGNORE}" | busybox grep -qF "${A}" ; then continue ; \
    else busybox echo " .. ${A}" && busybox rm -f /bin/${A} /usr/bin/${A} ; fi ; \
    done ; \
    busybox --install ; \
    echo "Build complete."

FROM scratch AS final
COPY --from=build / /

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-debian"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
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
