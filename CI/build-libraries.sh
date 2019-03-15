#!/bin/bash

# This is a script building libraries for CI
# It is *not* for general audience

LIBS="libapogee libfishcamp libfli libqhy libqsi libsbig"
SRC=$(cd "$(dirname "$0")"; cd .. ; pwd -P)

for libdir in ${SRC}/libs/* ; do
    lib=`basename ${libdir}`
    echo "Building $lib ..."
    mkdir -p build/$lib
    pushd build/$lib
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local . ${SRC}/libs/$lib
    make
    make install
    popd
done
