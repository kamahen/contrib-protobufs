#!/usr/bin/bash
# Run the protoc bootstrap.
# This is called from ../CMakeLists.txt
# Generates:
#   gen_pb/google/protobuf/descriptor_pb.pl and
#   gen_pb/google/protobuf/compiler/plugin_pb.pl
#
# NOTE: these are generated in the *source* directory because they're
#       kept in the source repository and need to be built only if
#       protoc adds some new .proto language feature.
#
# The script expects to be called during the build step with
# ${PROTOC_VERSION ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}

set -e -x
set -o pipefail

PROTOC_VERSION="$1"
SRCDIR=$(realpath "$2")
OUTDIR=$(realpath "$3")

# Typically, $SRCDIR is $(realpath $(dirname "$0")/..) but we
# shouldn't rely on that.

# export PROTOC_SRC=$HOME/tmp/protobuf-v${PROTOC_VERSION}
export PROTOC_SRC="$OUTDIR/bootstrap/downloads"

# wget -nv https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
# wget -nv https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protobuf-${PROTOC_VERSION}.zip
# mkdir -p zz
# cd zz
# unzip ../protoc-${PROTOC_VERSION}-linux-x86_64.zip
# unzip ../protobuf-${PROTOC_VERSION}.zip
# mv -i mv -i * $PROTOC_SRC

# At this point, we have $PROTOC_SRC/{bin,include/google,readme.txt}

tree $PROTOC_SRC

# The built swipl is in build/src and the downloaded protoc
# is in $PROTOC_SRC/bin:
export PATH=${PROTOC_SRC}/bin:$SRCDIR/bootstrap:$(realpath ${OUTDIR}/../../src):$PATH

PD=$(dirname $(type -p swipl))
type protoc-gen-swipl
swipl --dump_runtime_variables

make -j1 -C $SRCDIR/bootstrap check_vars
#   BUILD_BIN_DIR=  $HOME/src/swipl-devel/build.gcc/src/
#   SWIPL=          $HOME/src/swipl-devel/build.gcc/src/swipl
#   PROTOC=         $PROTOC_SRC/bin/protoc
#   PROTOC_INCLUDE= $PROTOC_SRC/include
#   PROTOC_GEN_PROLOG_PB=gen_pb

# TODO: not all of these files are needed:
# The following are because .PRECIOUS doesn't seem to work:
make -j4 -C $SRCDIR/bootstrap \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wire \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wiredump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wirerawdump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.parse \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wire \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wiredump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wirerawdump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.parse

make -j1 -C $SRCDIR/bootstrap \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.segment \

make -j1 -C $SRCDIR/bootstrap \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.segment

tree $PROTOC_SRC

# The *_pb.qlf files are only for generating error messages from *_pb.pl
make -j2 -C $SRCDIR/bootstrap \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor_pb.pl \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor_pb.qlf \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin_pb.pl \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin_pb.qlf

# tree $OUTDIR/bootstrap
tree $PROTOC_SRC

(cd $SRCDIR && git clean -n -dxf)
