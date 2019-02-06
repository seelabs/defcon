#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`"
    exit 1
fi


if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    apt-get update
    apt-get install -y --no-install-recommends \
            python3.7 \
            python3.7-dev \
            python3-distutils \
            texinfo
    dpkg -i gdb*amd64.deb
else
    version=${1}; shift
    apt-get update
    apt-get install -y --no-install-recommends \
            checkinstall \
            libncurses-dev \
            python3.7 \
            python3.7-dev \
            python3-distutils \
            texinfo

    curl -Lf https://ftp.gnu.org/gnu/gdb/gdb-${version}.tar.gz -o gdb.tar.gz
    tar xf gdb.tar.gz
    rm gdb.tar.gz
    pushd gdb-${version}
    ./configure --with-python=/usr/bin/python3.7 --enable-tui=yes
    make -j4
    checkinstall -y
    cp *.deb ../.
    popd # gdb-${version}
    rm -fr gdb-${version}
fi
