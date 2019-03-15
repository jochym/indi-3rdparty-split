#!/bin/bash

# This is a script building libraries for travis-ci
# It is *not* for general audience

LIBS="libapogee libfishcamp libfli libqhy libqsi libsbig"

for libdir in libs/* ; do
(
    lib=${libdir%%libs/}
    echo "Building $lib ..."
    mkdir build_$lib
    cd build_$lib
    cmake -DCMAKE_INSTALL_PREFIX=/usr . ../libs/$lib
    make
    make install
)
done
