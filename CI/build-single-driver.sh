#!/bin/bash

set -x -e

SRC=$(cd "$(dirname "$0")"; cd .. ; pwd -P)
DRV="indi-${1}"

echo "Building $DRV"
mkdir -p build/$DRV
pushd build/$DRV
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ . ${SRC}/drivers/$DRV -DFIX_WARNINGS=ON -DCMAKE_BUILD_TYPE=$1
make
popd

exit 0

