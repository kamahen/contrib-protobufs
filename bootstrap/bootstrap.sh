set -x -e

C=$(realpath $(dirname $0))
echo $C

# TODO: change rm to gen_pb/google but keep the repo files
#       (make clean ?)
(cd $C && rm -rf bootstrap/gen_pb/include && git clean -n -dxf)

export PROTO_SRC=$HOME/tmp/protobuf-v34.0

# wget -nv https://github.com/protocolbuffers/protobuf/releases/download/v34.0/protoc-34.0-linux-x86_64.zip
# wget -nv https://github.com/protocolbuffers/protobuf/releases/download/v34.0/protobuf-34.0.zip
# mkdir -p zz
# cd zz
# unzip ../protoc-34.0-linux-x86_64.zip
# unzip ../protobuf-34.0.zip
# mv -i mv -i * $PROTO_SRC

# At this point, we have $PROTOC_SRC/{bin,include,readme.txt,protobuf-34.0}

export PATH=$HOME/tmp/protobuf-v34.0/bin:$(realpath $C):$(realpath $C/../../../build.gcc/src/):$PATH

echo $PATH
PD=$(dirname $(type -p swipl))
type protoc-gen-swipl
swipl --dump_runtime_variables

make -j1 -C $C check_vars
#   BUILD_BIN_DIR=  $HOME/src/swipl-devel/build.gcc/src/
#   SWIPL=          $HOME/src/swipl-devel/build.gcc/src/swipl
#   PROTOC=         $HOME/tmp/protobuf-v34.0/bin/protoc
#   PROTOC_INCLUDE= $HOME/tmp/protobuf-v34.0/include
#   PROTOC_GEN_PROLOG_PB=gen_pb

mkdir -p $C/gen_pb/include/google/protobuf/compiler

# protoc -I$PROTOC_INCLUDE --include_imports --descriptor_set_out=gen_pb/include/google/protobuf/description.proto.wire $PROTOC_INCLUDE/google/protobuf/description.proto.wire
# protoc -I$PROTOC_INCLUDE --include_imports --descriptor_set_out=gen_pb/include/google/protobuf/description.proto.wire $PROTOC_INCLUDE/google/protobuf/description.proto

make -j1 -C $C gen_pb/google/protobuf/descriptor.proto.wire
make -j1 -C $C gen_pb/google/protobuf/compiler/plugin.proto.wire

make -j1 -C $C gen_pb/google/protobuf/descriptor.proto.wiredump
make -j1 -C $C gen_pb/google/protobuf/compiler/plugin.proto.wiredump

(cd $C && $PD/swipl -g "parse_wiredump('./gen_pb/include/google/protobuf/compiler/plugin.proto.wiredump')" -g halt parse_descriptor_proto_dump.pl >./gen_pb/include/google/protobuf/compiler/plugin.proto.parse)
(cd $C && $PD/swipl -g "parse_wiredump('./gen_pb/include/google/protobuf/descriptor.proto.wiredump')" -g halt parse_descriptor_proto_dump.pl >./gen_pb/include/google/protobuf/descriptor.proto.parse)

make -j1 -C $C all2

