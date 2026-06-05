#!/usr/bin/bash

# Download the needed files from the Google repository
# This is called from ../CMakeLists.txt

# The script expects to be called during the build step with
# ${PROTOC_VERSION} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}

# The build system should make the following files dependent on this
# script; that way, when the PROTOC_VERSION is changed, the new files will
# automatically be downloaded:
#     $OUTDIR/bootstrap/downloads/bin/protoc
#     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto
#     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto

set -e -x
set -o pipefail

PROTOC_VERSION="$1"
SRCDIR=$(realpath "$2")
OUTDIR=$(realpath "$3")

PROTOC_SRC="$OUTDIR/bootstrap/downloads"

rm -rf   "$PROTOC_SRC"
mkdir -p "$PROTOC_SRC"
cd       "$PROTOC_SRC"

curl -L --create-dirs \
     -o "protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
     https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
unzip -u "protoc-${PROTOC_VERSION}-linux-x86_64.zip"

# The following gets the source tree, which probably isn't needed:
# curl -L --create-dirs \
#      -o "protobuf-${PROTOC_VERSION}.zip" \
#      https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protobuf-${PROTOC_VERSION}.zip
# unzip "protobuf-${PROTOC_VERSION}.zip"
# ln -s "protobuf-${PROTOC_VERSION}" protobuf
