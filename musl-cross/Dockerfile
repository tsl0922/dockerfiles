FROM ubuntu:16.04

# https://github.com/coreos/bugs/issues/1095
RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        build-essential \
        cmake \
        curl \
        file \
        git \
        libtool \
        pkg-config \
        sudo \
        unzip \
        vim \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY config.mak /tmp/config.mak
RUN curl -sLo- https://github.com/richfelker/musl-cross-make/archive/v0.9.9.tar.gz | tar xz -C /tmp/ && \
    curl -sLo /tmp/1.diff https://github.com/richfelker/musl-cross-make/commit/a54eb56f33f255dfca60be045f12a5cfaf5a72a9.patch && \
    cd /tmp/musl-cross-make-0.9.9/ && mv /tmp/config.mak . && patch -p1 /tmp/1.diff && \
    TARGET=i386-linux-musl make install && \
    TARGET=x86_64-linux-musl make install && \
    TARGET=aarch64-linux-musl make install && \
    TARGET=arm-linux-musleabihf make install && \
    TARGET=arm-linux-musleabi make install && \
    TARGET=mips-linux-musl make install && \
    TARGET=mipsel-linux-musl make install && \
    TARGET=mips64-linux-musl make install && \
    TARGET=mips64el-linux-musl make install

ENV PATH="${PATH}:/opt/cross/bin"
