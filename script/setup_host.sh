#!/bin/bash
set -x
set -e
set -u

# git submodule add https://github.com/CXLMemUring/qemu lib/qemu || true
# git submodule add https://github.com/CXLMemUring/tigon workloads/tigon || true
git submodule update --init --depth 1 lib/qemu

sudo apt update && sudo apt install -y llvm-dev clang libbpf-dev libclang-dev python3-pip libcxxopts-dev libboost-dev nvidia-cuda-dev libfmt-dev libspdlog-dev librdmacm-dev
# python3 -m pip install --break-system-packages tomli
# python3 -m pip install --break-system-packages gdown
uv venv --python 3.12
source .venv/bin/activate
uv pip install tomli gdown
sudo apt install -y libglib2.0-dev libgcrypt20-dev zlib1g-dev \
    autoconf automake libtool bison flex libpixman-1-dev bc \
    make ninja-build libncurses-dev libelf-dev libssl-dev debootstrap \
    libcap-ng-dev libattr1-dev libslirp-dev libslirp0 libpmem-dev

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install -y gcc-13 g++-13

mkdir temp || echo "Don't worry. It is okay."
cd temp
wget https://github.com/Kitware/CMake/releases/download/v4.2.3/cmake-4.2.3.tar.gz
tar zxvf cmake-4.2.3.tar.gz 
cd cmake-4.2.3/
sudo ./bootstrap
sudo make -j$(nproc)
sudo make install
cmake --version
cd ../..
sudo rm -rf temp

cd ./lib/qemu
mkdir -p build || echo "Don't worry. It is okay."
cd build
../configure --prefix=/usr/local --target-list=x86_64-softmmu --enable-debug --enable-libpmem --enable-slirp
make -j$(nproc)
sudo make install
/usr/local/bin/qemu-system-x86_64 --version
