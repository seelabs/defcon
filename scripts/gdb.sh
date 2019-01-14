#!/usr/bin/env bash

set -ex

version=${1}

apt-get update
apt-get install -y --no-install-recommends \
        libncurses-dev \
        python3.7 \
        python3.7-dev \
        python3-distutils \
        texinfo \
;

curl -Lf https://ftp.gnu.org/gnu/gdb/gdb-${version}.tar.gz -o gdb.tar.gz
tar xf gdb.tar.gz
rm gdb.tar.gz
pushd gdb-${version}
./configure --with-python=/usr/bin/python3.7 --enable-tui=yes
make -j4
make install
popd # gdb-${version}
rm -fr gdb-${version}
