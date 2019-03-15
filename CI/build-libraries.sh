#!/bin/bash

# This is a script building libraries for travis-ci
# It is *not* for general audience

LIBS="libapogee libfishcamp libfli libqhy libqsi libsbig"
SRC=`dirname $0`/../

for libdir in ${SRC}/libs/* ; do
    lib=`basename ${libdir}`
    echo "Building $lib ..."
    mkdir -p build/$lib
    pushd build/$lib
    cmake -DCMAKE_INSTALL_PREFIX=/usr . ${SRC}/libs/$lib
    make
    make install
    popd
done
