cmake_minimum_required(VERSION 3.15)
project(swipl-protobufs)

# Flow of commands / files:
#   for F in compiler/plugin descritor:
#     protoc --descriptor_set_out      <$F.proto          >$F.proto.wire
#     descriptor_proto.pl              <$F.proto.wire     >$F.proto.segment
#     protoc --decode                  <$F.proto.wire     >$F.proto.wiredump
#     protoc --decode_raw              <$F.proto.wire     >$F.proto.wirerawdump
#     parse_descriptor_proto_dump.pl   <$F.proto.wiredump >$F.proto.parse
#     protoc --plugin=protoc-gen-swipl <$F.proto          >$F_pb.pl

option(BUILD_PROTOBUFS_PROTOC
       "Build the protobufs compiler plugin (protoc-gen-swipl)"
       OFF)
option(UPDATE_PROTOBUFS_PB
       "Copy the generated *_pb.pl files from the build tree to the source tree"
       OFF)

if(UPDATE_PROTOBUFS_PB AND NOT BUILD_PROTOBUFS_PROTOC)
  message(WARNING "Setting BUILD_PROTOBUFS_PROTOC=ON because UPDATE_PROTOBUFS_PB=${UPDATE_PROTOBUFS_PB}")
  set(BUILD_PROTOBUFS_PROTOC ON)
endif()

if(NOT BUILD_PROTOBUFS_PROTOC)
  return()
endif()

list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
message(DEBUG "build=${BUILD_PROTOBUFS_PROTOC} CmakeLists.txt<bootstrap> ${CMAKE_MODULE_PATH}")

include(FetchContent)
include(PrologPackage)
include(Ports)

set(path_with_swipl "$<TARGET_FILE_DIR:swipl>:$$PATH")

# We could test for
# ${download_base}/{bin/protoc,include/google/protobuf/{descriptor.proto,compiler/plugin.proto)}}
# existing, but this will do the wrong thing if PROTOC_VERSION
# changes, so depend on cmake to cache downloads (even though it
# probably doesn't).

set(download_name "download_protobuf_compiler")
set(protoc_url "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip")
message(DEBUG "Downloading ${download_name} from from ${protoc_url}")

FetchContent_Declare(
  "${download_name}"   # TODO: URL_HASH ...
  DOWNLOAD_EXTRACT_TIMESTAMP ON
  URL "${protoc_url}"
)
FetchContent_MakeAvailable("${download_name}")

set(download_base "${FETCHCONTENT_BASE_DIR}/${download_name}-src")
set(prog_protoc "${download_base}/bin/protoc")
set(gen_pb_binary_dir "${CMAKE_CURRENT_BINARY_DIR}/gen_pb")
set(prog_protoc_gen_swipl "${CMAKE_CURRENT_SOURCE_DIR}/protoc-gen-swipl")
# For protobufs_so, see https://github.com/SWI-Prolog/swipl-devel/issues/1600
cmake_path(SET protobufs_so "${CMAKE_CURRENT_BINARY_DIR}/../protobufs.so")
cmake_path(ABSOLUTE_PATH protobufs_so NORMALIZE)  # Nice, but not needed


message(DEBUG "PROG_SWIPL=${PROG_SWIPL}")
message(DEBUG "file: ${CMAKE_CURRENT_BINARY_DIR}/config_$<CONFIG>.txt")
message(DEBUG "file: Build Type: $<CONFIG>\n")
message(DEBUG "download_name: ${download_name}")
message(DEBUG "download_base: ${download_base}")
message(DEBUG "prog_protoc ${prog_protoc}")
message(DEBUG "prog_protoc_gen_swipl ${prog_protoc_gen_swipl}")
message(DEBUG "protobufs_so ${protobufs_so}")
message(DEBUG "MODULES=${CMAKE_MODULE_PATH}")

file(GENERATE
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config_$<CONFIG>.txt"
  CONTENT "Build Type: $<CONFIG>\nExecutable: $<TARGET_FILE:swipl>\n"
)

# TODO: This might not be needed:
file(GENERATE
     OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/protoc-gen-swipl.wrap"
     CONTENT "#!/bin/sh
exec ${PROG_SWIPL} \\
  ${prog_protoc_gen_swipl} \\
  -q -p protobuf='library\(ext/protobufs/protobufs/gen_pb/include\)' \"$@\"
  # TARGET_FILE=$<TARGET_FILE:swipl>
"
       FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

add_custom_command(
  COMMENT "copy downloaded github files to ${gen_pb_binary_dir}"
  VERBATIM
  OUTPUT "${gen_pb_binary_dir}/include/google/protobuf/descriptor.proto"
         "${gen_pb_binary_dir}/include/google/protobuf/compiler/plugin.proto"
  COMMAND cmake -E copy_directory "${download_base}/include"
                                  "${gen_pb_binary_dir}/include"
  # COMMAND cmake -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/gen_pb"
  #                                 "${CMAKE_CURRENT_BINARY_DIR}/gen_pb"
  DEPENDS "${download_base}/include/google/protobuf/descriptor.proto"
          "${download_base}/include/google/protobuf/compiler/plugin.proto"
          # home/library/ext/protobufs/bootstrap/gen_pb/include/google/protobuf/descriptor_pb.pl
)

foreach(in_proto_stem "descriptor" "compiler/plugin")
  string(REGEX REPLACE "/" "_" in_proto_flat "${in_proto_stem}")
  set(in_path "${gen_pb_binary_dir}/include/google/protobuf/${in_proto_stem}.proto")
  set(bin_path_pb "${gen_pb_binary_dir}/include/google/protobuf/${in_proto_stem}_pb.pl")

  add_custom_command(
    COMMENT "proto_to_wire ${in_path}"
    COMMAND cmake -E env
                  "${prog_protoc}"
                  "--proto_path=${gen_pb_binary_dir}/include"
                  "--include_imports"
                  "--descriptor_set_out=${in_path}.wire"
                  "${in_path}"
    OUTPUT "${in_path}.wire"
    DEPENDS "${prog_protoc}"
            "${in_path}"
    VERBATIM
  )

  add_custom_command(
    COMMENT "wire_to_wiredump ${in_path}"
    COMMAND cmake -E env
                  "${prog_protoc}"
                  "--proto_path=${gen_pb_binary_dir}/include"
                  --decode=google.protobuf.FileDescriptorSet
                  google/protobuf/descriptor.proto
                  < "${in_path}.wire"
                  > "${in_path}.wiredump"
    OUTPUT "${in_path}.wiredump"
    DEPENDS "${prog_protoc}"
            "${in_path}.wire"
    VERBATIM
  )

  add_custom_command(
    COMMENT "wire_to_segment ${in_path}"
    COMMAND cmake -E env
                  "${PROG_SWIPL}"
                  "${CMAKE_CURRENT_SOURCE_DIR}/descriptor_proto.pl"
                  < "${in_path}.wire"
                  > "${in_path}.segment"
    OUTPUT "${in_path}.segment"
    DEPENDS ${PROG_SWIPL} core prolog_home ${protobufs_so}
            "${in_path}.wire"
            "${CMAKE_CURRENT_SOURCE_DIR}/descriptor_proto.pl"
            "${CMAKE_CURRENT_SOURCE_DIR}/descriptor_proto_expand.pl"
    VERBATIM
  )

  add_custom_command(
    OUTPUT "${in_path}.parse"
    COMMENT "wiredump_to_parse ${in_path}"
    COMMAND cmake -E env
                  "${PROG_SWIPL}"
                  -g "parse_wiredump(\'${in_path}.wiredump\')"
                  -g halt
                  "${CMAKE_CURRENT_SOURCE_DIR}/parse_descriptor_proto_dump.pl"
                  > "${in_path}.parse"
    DEPENDS ${PROG_SWIPL} core prolog_home ${protobufs_so}
            "${in_path}.wiredump"
            "${CMAKE_CURRENT_SOURCE_DIR}/parse_descriptor_proto_dump.pl"
    VERBATIM
  )

  add_custom_command(
    OUTPUT "${in_path}.wirerawdump"
    COMMENT "wire_to_wirerawdump ${in_path}"
    COMMAND cmake -E env
                  "${PROG_PROTOC}"
                  --decode_raw
                  < "${in_path}.wire"
                  > "${in_path}.wirerawdump"
    DEPENDS ${PROG_PROTOC} "${in_path}.wire"
    VERBATIM
  )

  add_custom_command(
    COMMENT "proto_to_pb ${in_path}"
    # COMMAND cmake -E env ${prog_protoc} --version
    COMMAND cmake -E env "PATH=${path_with_swipl}"
                  "${prog_protoc}"
                  "-I${CMAKE_CURRENT_SOURCE_DIR}/.."
                  "-I${CMAKE_CURRENT_SOURCE_DIR}/../demo"
                  "-I${CMAKE_CURRENT_SOURCE_DIR}/../interop"
                  "-I${gen_pb_binary_dir}/include"
                  "--swipl_out=:${gen_pb_binary_dir}/include"
                  "--plugin=protoc-gen-swipl=${prog_protoc_gen_swipl}"
                  "${in_path}"

    # The "package" statement in the .proto file specifies where the
    # file is generated ... check that it's where expected:
    COMMAND cmake -E copy "${bin_path_pb}" "${bin_path_pb}-copy"  # Check file exists
    COMMAND cmake -E rm "${bin_path_pb}-copy"
    OUTPUT "${bin_path_pb}"
    DEPENDS ${PROG_SWIPL} core prolog_home ${protobufs_so}
            ${PROG_PROTOC_GEN_SWIPL}
            ${in_path}
            ${prog_protoc}
    VERBATIM)

  add_custom_target(
    "protobufs_bootstrap_pb_${in_proto_flat}" ALL
    COMMENT "protobufs bootstrap - make {$in_proto_stem}_pb.pl"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/config_$<CONFIG>.txt"
            "${CMAKE_CURRENT_BINARY_DIR}/protoc-gen-swipl.wrap" # TODO: not needed?
            # "${in_path}"
            # "${in_path}.wire"
            # "${in_path}.wiredump"
            "${in_path}.wirerawdump"
            "${in_path}.segment"
            "${in_path}.parse"
            "${bin_path_pb}"
  )
  if(UPDATE_PROTOBUFS_PB)
    set(src_path_pb "${CMAKE_CURRENT_SOURCE_DIR}/gen_pb/include/google/protobuf/${in_proto_stem}_pb.pl")

    add_custom_target(
      "protobufs_bootstrap_copy_built_pb_${in_proto_flat}" ALL
      COMMENT "copy built ${in_proto_stem}_pb.pl to source tree"
      DEPENDS "${bin_path_pb}"
      # Create qlf file to check for errors
      # COMMAND ${PROG_SWIPL} --undefined=error --verbose=false
      #      -p "protobuf='library(ext/protobufs/protobufs/gen_pb)'"
      #      -o "${bin_path_pb}.qlf"
      #      -c "${bin_path_pb}"
      COMMAND cmake -E copy
                    "${bin_path_pb}"
                    "${src_path_pb}"
    )
  endif()
endforeach()

