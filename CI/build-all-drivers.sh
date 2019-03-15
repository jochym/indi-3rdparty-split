#!/bin/bash

set -x -e

FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local -DFIX_WARNINGS=ON -DCMAKE_BUILD_TYPE=$1"

# The build-libs.sh must be run first for this to work
echo "Building all 3rd party drivers"
mkdir -p build/3rdparty
pushd build/3rdparty
cmake $FLAGS . ../../drivers/
make
popd

exit 0
