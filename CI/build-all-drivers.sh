#!/bin/bash

set -x -e

FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local -DFIX_WARNINGS=ON -DCMAKE_BUILD_TYPE=$1"
SRC=$(cd "$(dirname "$0")"; cd .. ; pwd -P)

# The build-libs.sh must be run first for this to work
echo "Building all 3rd party drivers"
mkdir -p build/drivers
pushd build/drivers
cmake $FLAGS . ${SRC}/drivers/
make
popd

exit 0
