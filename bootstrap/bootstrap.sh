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
# and expects $FETCHCONTENT_BASE_DIR to be populated with
# the necessary _*pb.pl files from the source directory.

set -e -x
set -o pipefail

echo === In bootstrap.sh $*

# export PROTOC_VERSION="$1"
# export CMAKE_CURRENT_SOURCE_DIR=$(realpath "$2")
# export CMAKE_CURRENT_BINARY_DIR=$(realpath "$3")

echo PROTOC_VERSION=$PROTOC_VERSION
echo CMAKE_CURRENT_SOURCE_DIR=$CMAKE_CURRENT_SOURCE_DIR
echo CMAKE_CURRENT_BINARY_DIR=$CMAKE_CURRENT_BINARY_DIR

# the .proto files are downloaded to $(CMAKE_CURRENT_BINARY_DIR):
export CMAKE_CURRENT_SOURCE_DIR_PB=$FETCHCONTENT_BASE_DIR/include
export CMAKE_CURRENT_BINARY_DIR_PB=$FETCHCONTENT_BASE_DIR/include

# The built swipl is in build/src and the downloaded protoc
# is in $FETCHCONTENT_BASE_DIR/bin:
export PATH=${FETCHCONTENT_BASE_DIR}/bin:$CMAKE_CURRENT_SOURCE_DIR/bootstrap/src::$PATH

export MAKE_="make -j1 --warn-undefined-variables -C $CMAKE_CURRENT_SOURCE_DIR"

$MAKE_ check_vars

# At this point, we have $FETCHCONTENT_BASE_DIR/{bin,include/google,readme.txt}
tree $FETCHCONTENT_BASE_DIR

echo '======'

type -p swipl
# set | grep SWI
swipl --version
swipl --dump_runtime_variables

$MAKE_ check_vars

# TODO: not all of these files are needed:
# *.wirerawdump are only for debugging
# The intermediate files are specified because .PRECIOUS doesn't seem to work.
$MAKE_ \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor.proto.wire \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor.proto.wiredump \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor.proto.wirerawdump \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor.proto.parse \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin.proto.segment \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor.proto.segment \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin.proto.wire \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin.proto.wiredump \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin.proto.wirerawdump \
     $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin.proto.parse

# tree $FETCHCONTENT_BASE_DIR

# The *_pb.qlf files are only for generating error messages from *_pb.pl
$MAKE_ $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/descriptor_pb.pl \
       $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/descriptor_pb.qlf \
       $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/compiler/plugin_pb.pl \
       $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/compiler/plugin_pb.qlf

rm -f $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/descriptor_pb.qlf \
      $CMAKE_CURRENT_BINARY_DIR_PB/google/protobuf/compiler/plugin_pb.qlf

# tree $CMAKE_CURRENT_BINARY_DIR/bootstrap
# tree $FETCHCONTENT_BASE_DIR

# The following will fail if $CMAKE_CURRENT_SOURCE_DIR is read-only

(
    set -x
    cp $FETCHCONTENT_BASE_DIR/include/google/protobuf/descriptor_pb.pl \
       $CMAKE_CURRENT_SOURCE_DIR/bootstrap/gen_pb/google/protobuf/descriptor_pb.pl
    cp $FETCHCONTENT_BASE_DIR/include/google/protobuf/compiler/plugin_pb.pl \
       $CMAKE_CURRENT_SOURCE_DIR/bootstrap/gen_pb/google/protobuf/compiler/plugin_pb.pl
)

# (cd $CMAKE_CURRENT_SOURCE_DIR && git clean -n -dxf)
