#!/usr/bin/env bash

set -exo pipefail

if [[ ${#} -ne 1 ]]; then
    echo "script must be called with either a version number or `install`"
    exit 1
fi

if [[ ${1} == "install" ]]; then
    # script must be started in the directory that contains the .deb file
    dpkg -i qt*amd64.deb
else
    QT_VERSION=${1}; shift
    # remove the patch i.e. if QT_VERSION is 5.10.1, QT_VERSION_MAJOR_ will be 5.10
    QT_VERSION_MAJOR=$(echo "${QT_VERSION}" | awk 'BEGIN {FS="."}{print $1"."$2}')

    apt-get update
    apt-get -y install -y \
            perl python git \
            build-essential libxcb1-dev libicu-dev \
            checkinstall \
            libssl-dev linux-headers-generic curl git libxrender-dev \
            libpng16-16 libpng-dev libjpeg-turbo8 libjpeg-turbo8-dev libicu60 libicu-dev \
            libgles2-mesa libgles2-mesa-dev libfreetype6-dev libsqlite3-dev \
            libgstreamer1.0 libgstreamer1.0-dev \
            libogg-dev libvorbis-dev bzip2 gperf bison ruby flex
    rm -rf /var/lib/apt/lists/*

    mkdir qt_build
    pushd qt_build
    if [[ ${QT_VERSION_MAJOR} = 5.9 ]]; then
        QT_DIR_NAME=qt-everywhere-opensource-src-${QT_VERSION}
    else
        QT_DIR_NAME=qt-everywhere-src-${QT_VERSION}
    fi
    curl -Lf https://download.qt.io/official_releases/qt/${QT_VERSION_MAJOR}/${QT_VERSION}/single/${QT_DIR_NAME}.tar.xz -o qt.tar.xz
    tar xf qt.tar.xz
    rm qt.tar.xz
    pushd ${QT_DIR_NAME}

    ./configure \
        -opensource -confirm-license \
        -shared \
        -sql-sqlite -sqlite \
        -no-harfbuzz -qt-pcre -no-dbus \
        -no-xkbcommon-evdev -no-xinput2 -no-xcb-xlib -no-glib -qt-xcb -no-compile-examples -nomake examples

    make -j4
    checkinstall -y
    cp *.deb ../../.

    popd # ${QT_DIR_NAME}
    popd # qt_build
    rm -fr qt_build
fi
