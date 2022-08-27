FROM debian:11.4 as builder
WORKDIR /tmp
RUN git clone https://git.busybox.net/busybox busybox && git checkout remotes/origin/1_35_stable && git pull
RUN cd /tmp/busybox && make defconfig && make

FROM debian:11.4-slim

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-debian"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=1 \
    # path to bf executables
    BF_BIN=/usr/bin/bf \
    # path to bf library executables
    BF_LIB=/usr/lib/bf

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./11/overlay /
COPY --from=builder /tmp/busybox /usr/busybox

RUN chmod +x ${BF_BIN}/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
