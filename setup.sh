#!/bin/sh

# init
dnf group install -y 'Development Tools'
dnf --enablerepo=PowerTools install -y ocaml ocaml-ocamlbuild redhat-rpm-config openssl-devel wget rpm-build git cmake perl python2 libcurl-devel protobuf-devel && \
    alternatives --set python /usr/bin/python2

# binutils
curl -o binutils.tar.xz https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz && \
    tar xf binutils.tar.xz && \
    cd binutils-2.35 && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr/local --enable-gold --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64-bit-bfd --with-system-zlib && \
    make -j "$(nproc)" && \
    make install && \
    cd /root && \
    rm -rf binutils-gdb

# sdk
cd /root && \
    git clone --recursive https://github.com/intel/linux-sgx && \
    cd linux-sgx && \
    git checkout 608fe1df4c7c99433b0b8e9abdd31ba67c79ceb0 && \
    ./download_prebuilt.sh && \
    make -j "$(nproc)" sdk_install_pkg && \
    echo -e 'no\n/opt' | ./linux/installer/bin/sgx_linux_x64_sdk_2.12.100.3.bin && \
    echo 'source /opt/sgxsdk/environment' >> /root/.bashrc && \
    cd /root && \
    rm -rf /root/linux-sgx
