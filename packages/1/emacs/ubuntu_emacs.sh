#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`" >&2
    exit 1
fi

if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    apt-get update
    apt-get install -y  \
            gnupg \
            imagemagick \
            ispell \
            libcanberra-gtk3-module \
            libdbus-1-dev \
            libgif-dev \
            libgnutls28-dev \
            libgpm-dev \
            libgtk-3-dev \
            libjpeg-dev \
            liblockfile-dev \
            libm17n-dev \
            libmagick++-6.q16-dev \
            libncurses5-dev \
            libotf-dev \
            libpng-dev \
            librsvg2-dev \
            libselinux1-dev \
            libtiff-dev \
            libxaw7-dev \
            libxml2-dev \
            openssh-client
    dpkg -i emacs*amd64.deb
else
    version=${1}; shift
    apt-get update
    apt-get install -y \
            autoconf \
            automake \
            autotools-dev \
            build-essential \
            checkinstall \
            curl \
            dpkg-dev \
            git \
            gnupg \
            imagemagick \
            ispell \
            libacl1-dev \
            libasound2-dev \
            libcanberra-gtk3-module \
            libdbus-1-dev \
            libgif-dev \
            libgnutls28-dev \
            libgpm-dev \
            libgtk-3-dev \
            libjpeg-dev \
            liblockfile-dev \
            libm17n-dev \
            libmagick++-6.q16-dev \
            libncurses5-dev \
            libotf-dev \
            libpng-dev \
            librsvg2-dev \
            libselinux1-dev \
            libtiff-dev \
            libxaw7-dev \
            libxml2-dev \
            openssh-client \
            python \
            texinfo \
            xaw3dg-dev \
            zlib1g-dev
    rm -rf /var/lib/apt/lists/*

    curl -Lf https://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.gz -o emacs.tar.gz
    tar xf emacs.tar.gz
    rm emacs.tar.gz
    pushd emacs-${version}
    ./autogen.sh
    ./configure
    make -j4
    checkinstall -y
    cp *.deb ../.
    popd # emacs-${version}
    rm -fr emacs-${version}
fi
