#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`"
    exit 1
fi

if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    dpkg -i build-llvm*amd64.deb
else
    version=${1}; shift
    # branch=trunk # to get trunk
    branch=branches/release_${version}0

    top_level_llvm=llvm-${version}
    llvm_d=$(pwd)/${top_level_llvm}
    tools_d=${llvm_d}/tools
    build_dir=build-${top_level_llvm}
    start_dir=$(pwd)

    apt-get update
    apt-get install -y --no-install-recommends \
            checkinstall \
            cmake \
            subversion \
            python

    svn co http://llvm.org/svn/llvm-project/llvm/${branch} ${top_level_llvm}
    cd ${tools_d}
    svn co http://llvm.org/svn/llvm-project/cfe/${branch} clang
    cd ${tools_d}
    svn co http://llvm.org/svn/llvm-project/lld/${branch} lld
    cd ${tools_d}/clang/tools
    svn co http://llvm.org/svn/llvm-project/clang-tools-extra/${branch} extra
    cd ${llvm_d}/projects
    svn co http://llvm.org/svn/llvm-project/compiler-rt/${branch} compiler-rt
    cd ${llvm_d}/projects
    svn co http://llvm.org/svn/llvm-project/libcxx/${branch} libcxx
    cd ${llvm_d}/projects
    svn co http://llvm.org/svn/llvm-project/libcxxabi/${branch} libcxxabi

    cd ${start_dir}

    # When building disable tests and examples
    if [[ -d ${build_dir} ]]; then
        print "Build dir ${build_dir} exists. Cowardly refusing to build."
        exti 1
    fi

    mkdir -p ${build_dir} && cd ${build_dir}
    cmake -DCMAKE_BUILD_TYPE=Release ${llvm_d}
    cmake --build . -- -j4
    checkinstall -y cmake --build . --target install
    cp *.deb ../.
    cd ..
    rm -fr ${top_level_llvm}
    rm -fr ${build_dir}
fi
