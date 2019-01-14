#!/usr/bin/env bash

set -ex

version=${1}
version_=${version//./_} # i.e. if version is 1.68.0, version_ will be 1_68_0

curl -Lf https://dl.bintray.com/boostorg/release/${version}/source/boost_${version_}.tar.gz -o boost.tar.gz
tar xf boost.tar.gz
rm boost.tar.gz
pushd boost_${version_}
./bootstrap.sh
./b2 headers
./b2 --without-python -j4
./b2 install --without-python
popd # boost_${version_}
rm -fr boost_${version_}
