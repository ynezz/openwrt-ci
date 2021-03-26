FROM debian:testing
MAINTAINER OpenWrt Maintainers

ARG DEBIAN_FRONTEND=noninteractive

RUN \
        apt-get update && apt-get install -y curl gnupg2 && \
        curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
        echo "deb http://apt.llvm.org/unstable/ llvm-toolchain-11 main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        cppcheck \
        clang-11 \
        clang-tools-11 \
        file \
        gawk \
        gcc-9 \
        gcc-10 \
        git \
        locales \
        libbfd-dev \
        libc++-11-dev \
        libc++abi-11-dev \
        libcmocka0 \
        libmbedtls-dev \
        libncurses5 \
        libncurses5-dev \
        libssl-dev \
        liblua5.1-0-dev \
        libwolfssl-dev \
        libunwind-dev \
        lua5.1 \
        python2.7 \
        python3 \
        python3-venv \
        sudo \
        unzip \
        valgrind \
        wget \
        zlib1g-dev

RUN echo 'deb http://deb.debian.org/debian buster main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y libisl19 libmpx2
RUN apt-get download gcc-8 gcc-8-base cpp-8 libgcc-8-dev
RUN dpkg -i --force-all *.deb

RUN rm -rf /var/lib/apt/lists/* && rm -fr /var/cache/apt

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

WORKDIR /opt

ENV JSONC_TAG=json-c-0.15-20200726
RUN git clone https://github.com/json-c/json-c && cd json-c && git reset --hard $JSONC_TAG
RUN \
	mkdir build && \
	cmake -S $(pwd)/json-c -B $(pwd)/build -DCMAKE_INSTALL_PREFIX=/usr && \
	make -j$(($(nproc)+1)) -C $(pwd)/build all install

ENV AFL_COMMIT=1cc1a0985039
RUN git clone https://github.com/google/AFL && cd AFL && git reset --hard $AFL_COMMIT
RUN make -j$(($(nproc)+1)) -C AFL all install

ENV HONGFUZZ_COMMIT=cf5f34a
RUN \
    git clone https://github.com/google/honggfuzz && \
    cd honggfuzz && \
    git reset --hard $HONGFUZZ_COMMIT && \
    make -j$(($(nproc)+1)) all install

RUN rm -fr /opt/*

RUN \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    useradd -c "OpenWrt Builder" -m -d /home/build -G sudo -s /bin/bash build
COPY --chown=build:build files/build.sh /home/build/openwrt/build.sh
RUN chmod ug=rwx,o=rx /home/build/openwrt/build.sh
RUN chown build:build /home/build/openwrt

USER build
ENV HOME /home/build
WORKDIR /home/build/openwrt/
RUN ./build.sh && rm -fr ./*

VOLUME [ "/home/build/openwrt" ]
