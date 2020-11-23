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

#psw
export PSW_REPO="https://download.01.org/intel-sgx/sgx-linux/2.12/distro/centos8.2-server/sgx_rpm_local_repo.tgz"

cd /root && \
curl --output /root/repo.tgz $PSW_REPO && \
cd /root && \
tar xzf repo.tgz && \
cd sgx_rpm_local_repo && \
rpm -ivh ./*.rpm && \
cd /root && \
mkdir /var/run/aesmd && \
rm -rf sgx_rpm_local_repo repo.tgz


#rust
export rust_toolchain=nightly-2020-10-25

cd /root && \
curl 'https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init' --output /root/rustup-init && \
chmod +x /root/rustup-init && \
echo '1' | /root/rustup-init --default-toolchain ${rust_toolchain} && \
echo 'source /root/.cargo/env' >> /root/.bashrc && \
/root/.cargo/bin/rustup component add rust-src rls rust-analysis clippy rustfmt && \
/root/.cargo/bin/cargo install xargo && \
rm -f /root/rustup-init && rm -rf /root/.cargo/registry && rm -rf /root/.cargo/git
