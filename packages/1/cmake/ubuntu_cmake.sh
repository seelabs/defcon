#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`"
    exit 1
fi

if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    dpkg -i cmake*amd64.deb
else
    version=${1}; shift
    apt-get update
    apt-get install -y --no-install-recommends \
            checkinstall \
            libcurl4-openssl-dev \
            zlib1g-dev

    curl -Lf https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}.tar.gz -o cmake.tar.gz
    tar xf cmake.tar.gz
    rm cmake.tar.gz
    pushd cmake-${version}
    ./bootstrap --system-curl
    make -j4
    checkinstall -y
    cp *.deb ../.
    popd # cmake-${version}
    rm -fr cmake-${version}
fi
