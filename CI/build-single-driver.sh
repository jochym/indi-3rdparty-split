#!/bin/bash

set -x -e

DRV="indi-${1}"
echo "Building $DRV"
mkdir -p build/$DRV
pushd build/$DRV
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ . ../../drivers/$DRV -DFIX_WARNINGS=ON -DCMAKE_BUILD_TYPE=$1
make
popd

exit 0

