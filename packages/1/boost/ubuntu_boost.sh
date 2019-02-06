#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`"
    exit 1
fi

if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    dpkg -i boost*amd64.deb
else
    version=${1}; shift
    version_=${version//./_} # i.e. if version is 1.68.0, version_ will be 1_68_0

    apt-get update
    apt-get install -y --no-install-recommends \
            checkinstall

    curl -Lf https://dl.bintray.com/boostorg/release/${version}/source/boost_${version_}.tar.gz -o boost.tar.gz
    tar xf boost.tar.gz
    rm boost.tar.gz
    pushd boost_${version_}
    ./bootstrap.sh
    ./b2 headers
    ./b2 --without-python -j4
    checkinstall -y ./b2 install --without-python
    cp *.deb ../.
    popd # boost_${version_}
    rm -fr boost_${version_}
fi
