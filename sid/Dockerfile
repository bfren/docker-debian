FROM debian:sid as builder

WORKDIR /tmp

RUN apt update && apt install --no-install-recommends -y git && \
    git clone https://git.busybox.net/busybox busybox && git checkout remotes/origin/1_35_stable && \
    cd /tmp/busybox && make defconfig && make

FROM debian:sid-slim

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
COPY ./sid/overlay /
COPY --from=builder /tmp/busybox /usr/busybox

RUN chmod +x ${BF_BIN}/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
