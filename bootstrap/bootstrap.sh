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
# and expects $OUTDIR/bootstrap/downloads to be populated with
# the necessary _*pb.pl files from the source directory.

set -e # -x
set -o pipefail

export PROTOC_VERSION="$1"
export SRCDIR=$(realpath "$2")
export OUTDIR=$(realpath "$3")

# the .proto files are downloaded to $(OUTDIR):
export SRCDIR_PB=$OUTDIR/bootstrap/downloads/include
export OUTDIR_PB=$OUTDIR/bootstrap/downloads/include

export MAKE_="make OUTDIR_PB=$OUTDIR_PB -j4 --warn-undefined-variables -C $SRCDIR/bootstrap"

# Typically, $SRCDIR is $(realpath $(dirname "$0")/..) but shouldn't
# rely on that.

# export PROTOC_SRC=$HOME/tmp/protobuf-v${PROTOC_VERSION}
export PROTOC_SRC="$OUTDIR/bootstrap/downloads"

# At this point, we have $PROTOC_SRC/{bin,include/google,readme.txt}

# tree $PROTOC_SRC

# The built swipl is in build/src and the downloaded protoc
# is in $PROTOC_SRC/bin:
export PATH=${PROTOC_SRC}/bin:$SRCDIR/bootstrap:$(realpath ${OUTDIR}/../../src):$PATH

PD=$(dirname $(type -p swipl))
type protoc-gen-swipl
set | grep SWI
$PD/swipl --version
$PD/swipl --dump_runtime_variables

$MAKE_ check_vars
#   BUILD_BIN_DIR=  $HOME/src/swipl-devel/build.gcc/src/
#   SWIPL=          $HOME/src/swipl-devel/build.gcc/src/swipl
#   PROTOC=         $PROTOC_SRC/bin/protoc
#   PROTOC_INCLUDE= $PROTOC_SRC/include
#   PROTOC_GEN_PROLOG_PB=gen_pb

# TODO: not all of these files are needed:
# *.wirerawdump are only for debugging
# The intermediate files are specified because .PRECIOUS doesn't seem to work.
$MAKE_ \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wire \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wiredump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.wirerawdump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.parse \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.segment \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor.proto.segment \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wire \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wiredump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.wirerawdump \
     $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin.proto.parse

# tree $PROTOC_SRC

# The *_pb.qlf files are only for generating error messages from *_pb.pl
$MAKE_ $OUTDIR_PB/google/protobuf/descriptor_pb.pl \
       $OUTDIR_PB/google/protobuf/descriptor_pb.qlf \
       $OUTDIR_PB/google/protobuf/compiler/plugin_pb.pl \
       $OUTDIR_PB/google/protobuf/compiler/plugin_pb.qlf

rm -f $OUTDIR_PB/google/protobuf/descriptor_pb.qlf \
      $OUTDIR_PB/google/protobuf/compiler/plugin_pb.qlf

# tree $OUTDIR/bootstrap
# tree $PROTOC_SRC

# The following will fail if $SRCDIR is read-only

(
    set -x
    cp $OUTDIR/bootstrap/downloads/include/google/protobuf/descriptor_pb.pl \
       $SRCDIR/bootstrap/gen_pb/google/protobuf/descriptor_pb.pl
    cp $OUTDIR/bootstrap/downloads/include/google/protobuf/compiler/plugin_pb.pl \
       $SRCDIR/bootstrap/gen_pb/google/protobuf/compiler/plugin_pb.pl
)

# (cd $SRCDIR && git clean -n -dxf)
