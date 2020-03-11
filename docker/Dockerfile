FROM debian:testing
MAINTAINER OpenWrt Maintainers

ARG DEBIAN_FRONTEND=noninteractive

RUN \
        apt-get update && apt-get install -y curl gnupg2 && \
        curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
        echo "deb http://apt.llvm.org/unstable/ llvm-toolchain-9 main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        cppcheck \
        clang-9 \
        clang-tools-9 \
        file \
        gawk \
        gcc-7 \
        gcc-8 \
        git \
        locales \
        libc++-9-dev \
        libc++abi-9-dev \
        libcmocka0 \
        libncurses5 \
        libncurses5-dev \
        libssl-dev \
        libjson-c-dev \
        liblua5.1-0-dev \
        lua5.1 \
        python2.7 \
        python3 \
        python3-venv \
        sudo \
        unzip \
        valgrind \
        wget \
        zlib1g-dev && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

RUN \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    useradd -c "OpenWrt Builder" -m -d /home/build -G sudo -s /bin/bash build
COPY --chown=build:build files/build.sh /home/build/openwrt/build.sh
RUN chmod ug=rwx,o=rx /home/build/openwrt/build.sh

# FIXME: this timeouts after 90min when running under docker-dind on GitLab CI shared runners
#RUN chown build:build /home/build/openwrt

USER build
ENV HOME /home/build
WORKDIR /home/build/openwrt/
RUN ./build.sh

VOLUME [ "/home/build/openwrt" ]
