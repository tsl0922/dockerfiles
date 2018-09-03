FROM ubuntu:16.04

# https://github.com/coreos/bugs/issues/1095
RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        bsdtar \
        build-essential \
        cmake \
        curl \
        file \
        git \
        pkg-config \
        sudo \
        unzip \
        vim \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mv /bin/tar /bin/tar.bak && ln -sf $(which bsdtar) /bin/tar

COPY config.mak /tmp/config.mak
RUN git clone --depth=1 https://github.com/richfelker/musl-cross-make.git /tmp/musl-cross-make && \
	mv /tmp/config.mak /tmp/musl-cross-make/config.mak && \
    TARGET=i386-linux-musl make -C /tmp/musl-cross-make install && \
    TARGET=x86_64-linux-musl make -C /tmp/musl-cross-make install && \
    TARGET=aarch64-linux-musl make -C /tmp/musl-cross-make install && \
    TARGET=arm-linux-musleabihf make -C /tmp/musl-cross-make install && \
    TARGET=arm-linux-musleabi make -C /tmp/musl-cross-make install && \
    TARGET=mips-linux-musl make -C /tmp/musl-cross-make install && \
    TARGET=mipsel-linux-musl make -C /tmp/musl-cross-make install && \
    rm -rf /tmp/musl-cross-make && mv -f /bin/tar.bak /bin/tar

ENV PATH="${PATH}:/opt/cross/bin"
