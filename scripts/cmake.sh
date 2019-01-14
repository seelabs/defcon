#!/usr/bin/env bash

set -ex

version=${1}

apt-get update
apt-get install -y --no-install-recommends \
        zlib1g-dev \
        libcurl4-openssl-dev \
    ;

curl -Lf https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}.tar.gz -o cmake.tar.gz
tar xf cmake.tar.gz
rm cmake.tar.gz
pushd cmake-${version}
./bootstrap --system-curl
make -j4
make install
popd # cmake-${version}
rm -fr cmake-${version}
