FROM debian:10.12 as builder

WORKDIR /tmp

RUN apt update && apt install --no-install-recommends -y gcc git libc6-dev make && \
    git clone git://busybox.net/busybox.git . && git checkout remotes/origin/1_35_stable && \
    make defconfig && make

FROM debian:10.12-slim

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
COPY ./10/overlay /
COPY --from=builder /tmp/busybox /bin/busybox

RUN chmod +x ${BF_BIN}/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
