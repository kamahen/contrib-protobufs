cmake_minimum_required(VERSION 3.10)
project(swipl-protobufs)

message(INFO " CmakeLists.txt<bootstrap>")
include("../../cmake/PrologPackage.cmake")
message(INFO " build=${BUILD_PROTOBUFS_PROTOC} CmakeLists.txt<bootstrap> ${CMAKE_MODULE_PATH}")

set(PROG_PROTOC "${FETCHCONTENT_BASE_DIR}/bin/protoc")
set(PROG_PROTOC_GEN_SWIPL "${CMAKE_CURRENT_SOURCE_DIR}/protoc-gen-swipl}")

function(cmd_proto_to_wire in_path)
  add_custom_command(
    OUTPUT "${in_path}.wire"
    COMMENT "proto_to_wire for ${in_path} $PROG_PROTOC --proto_path=${PROTOC_INCLUDE}"
    COMMAND cmake -E env
                  $PROG_PROTOC --proto_path=${PROTOC_INCLUDE}
                  --include_imports
                  --descriptor_set_out=${in_path}.wire
                  ${in_path}
    DEPENDS $PROG_PROTOC ${in_path} ${ARGN}
    VERBATIM)
endfunction()

function(cmd_wire_to_wiredump in_path)
  add_custom_command(
    OUTPUT "${in_path}.wiredump"
    COMMENT "wire_to_wiredump for ${in_path} $PROG_PROTOC --proto_path=${PROTOC_INCLUDE}"
    COMMAND cmake -E env
                  $PROG_PROTOC --protopath=${PROTOC_INCLUDE}
                  --decode=google.protobuf.FileDescriptorSet
                  <${in_path}.wire >${in_path}.wiredump
    DEPENDS ${PROG_PROTOC} ${in_path}.wire ${ARGN}
    VERBATIM)
endfunction()

function(cmd_wire_to_segment in_path)
  add_custom_command(
    OUTPUT "${in_path}.segment"
    COMMENT "wire_to_segment for ${in_path}"
    COMMAND cmake -E env
                  $(PROG_SWIPL)
                  ${CMAKE_CURRENT_SOURCE_DIR}/descriptor_proto.pl
                  <${in_path}.wire
                  >${in_path}.segment
    DEPENDS ${PROG_PROTOC} "${in_path}.wire" ${ARGN}
            "${CMAKE_CURRENT_SOURCE_DIR}/descriptor_proto.pl"
    VERBATIM)
endfunction()

function(cmd_wiredump_to_parse in_path)
  add_custom_command(
    OUTPUT "${in_path}.parse"
    COMMENT "wiredump_to_parse for ${in_path}"
    COMMAND cmake -E env
                  $(PROG_SWIPL)
                  -g parse_wiredump(${in_path}.wiredump)
                  -g halt
                  ${CMAKE_CURRENNT_SOURCE_DIR}/pares_descriptor_proto_dump.pl
                  >${in_path}.parse
    DEPENDS ${PROG_PROTOC} "${in_path}.wiredump" ${PROG_SWIPL}
            ${CMAKE_CURRENNT_SOURCE_DIR}/pares_descriptor_proto_dump.pl
    VERBATIM)
endfunction()

function(cmd_wire_to_wirerawdump in_path)
  add_custom_command(
    OUTPUT "${in_path}.wirerawdump"
    COMMENT "wire_to_wirerawdump for ${in_path}"
    COMMAND cmake -E env
                  ${PROG_PROTOC}
                  --decode_raw
                  <${in_path}.wire
                  >${in_path.wirerawdump}
    DEPENDS ${PROG_PROTOC} $in_path ${ARGN}
    VERBATIM)
endfunction()

function(cmd_proto_to_pb2 in_path)
  cmake_path(GET in_path STEM LAST_ONLY in_path_stem)
  set(out_path "${in_path_stem}_pb.pl")
  message(STATUS "Generating ${out_path} from ${in_path}")
  add_custom_command(
    OUTPUT "${out_path}"
    COMMENT "proto_to_pb2 for ${in_path}"
    COMMAND cmake -E env ${PROG_PROTOC} --version
    COMMAND cmake -E env PATH=${path_with_swipl}
                  ${PROG_PROTOC} ${PROTOC_I} "--swpl_out=':${CMAKE_CURRENT_BINARY_DIR_PB}'"
                  --plugin=protoc-gen-swipl=${PROG_PROTOC_GEN_SWIPL}
                  ${in_path}
    DEPENDS ${PROG_PROTOC_GEN_SWIPL} ${in_path} ${PROG_PROTOC} core prolog_home
    VERBATIM)
endfunction()

function(cmd_chain in_path)
  cmd_proto_to_wire(${in_path})
  cmd_wire_to_wiredump(${in_path})
  cmd_wire_to_segment(${in_path})
  cmd_wiredump_to_parse(${in_path})
  cmd_wire_to_wirerawdump(${in_path})
  cmd_proto_to_pb2(${in_path} ${ARGN})
endfunction()

if(BUILD_PROTOBUFS_PROTOC)
  include(FetchContent)
  include(PrologPackage)
  include(Ports)

  message(STATUS "PROG_SWIPL=${PROG_SWIPL}")
  message(STATUS "SWIPL_NATIVE_FRIEND=${SWIPL_NATIVE_FRIEND}")
  message(STATUS "SWIPL_NATIVE_FRIEND_DIR=${SWIPL_NATIVE_FRIEND_DIR}")
  set(path_with_swipl "$<TARGET_FILE:swipl>:$$PATH")
  message(STATUS "file: ${CMAKE_CURRENT_BINARY_DIR}/config_$<CONFIG>.txt")
  message(STATUS "file: Build Type: $<CONFIG>\nExecutable: $<TARGET_FILE:swipl>\n")

  file(GENERATE
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config_$<CONFIG>.txt"
    CONTENT "Build Type: $<CONFIG>\nExecutable: $<TARGET_FILE:swipl>\n"
  )

  list(JOIN PROG_SWIPL " " prog_swipl_cmd)
  file(GENERATE
       OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/protoc-gen-swipl.xxx"
       CONTENT "#!/bin/sh
exec ${prog_swipl_cmd} \\
  ${CMAKE_CURRENT_SOURCE_DIR}/protoc-gen-swipl \\
  -q -p protobuf='library\(ext/protobufs/protobufs/gen_pb\)' \"$@\"
  # TARGET_FILE=$<TARGET_FILE:swipl>
"
       FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                        GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

  # We could test for downloads/{bin/protoc,include/google/protobuf/{descriptor.proto,compiler/plugin.proto)}}
  # existing, but this will do the wrong thing if PROTOC_VERSION changes,
  # so depend on cmake to cache downloads (even though it probably doesn't).
  block()
    message(STATUS "Downloading Google protobuf files to ${CMAKE_CURRENT_BINARY_DIR}/download_protobuf_compiler-src")
    set(PROTOC_URL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip")
    message(STATUS "   from ${PROTOC_URL}")
    set(FETCHCONTENT_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
    FetchContent_Declare(
      download_protobuf_compiler
      # URL_HASH ...
      DOWNLOAD_EXTRACT_TIMESTAMP ON
      LOG_DOWNLOAD ON
      URL "${PROTOC_URL}"
    )
    FetchContent_MakeAvailable(download_protobuf_compiler)

    cmd_chain(downloads/include/google/protobuf/descriptor)
    cmd_chain(downloads/include/google/protobuf/compiler/plugin
              downloads/include/google/protobuf/descriptor_pb.pl)

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/protoc-gen-swipl"
      COMMENT "Bootstrapping protoc-gen-swipl in ${CMAKE_CURRENT_BINARY_DIR}"
      DEPENDEES download_protobuf_compiler
      # DEPENDS download_protobuf_compiler-src/downloads/bin/protoc
      #         download_protobuf_compiler-src/downloads/include/google/protobuf/descriptor.proto
      #         download_protobuf_compiler-src/downloads/include/google/protobuf/compiler/plugin.proto
      COMMAND cmake -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/gen_pb"
      COMMAND cmake -E copy_directory "${CMAKE_CURRENT_BINARY_DIR}/download_protobuf_compiler-src"
                                      "${CMAKE_CURRENT_BINARY_DIR}/downloads"
      COMMAND cmake -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/gen_pb"
                                      "${CMAKE_CURRENT_BINARY_DIR}/gen_pb"
      # COMMAND cmake -E env PROTOC_VERSION=${PROTOC_VERSION}
      #                      PROG_PROTOC=${PROG_PROTOC}
      #                      PROG_SWIPL=${PROG_SWIPL}
      #                      FETCHCONTENT_BASE_DIR=${FETCHCONTENT_BASE_DIR}
      #                      CMAKE_CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
      #                      CMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
      #           ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap.sh
      DEPENDS core prolog_home
      VERBATIM COMMAND_EXPAND_LISTS
      )
    add_custom_target(
         bootstrap-protoc-gen-swipl ALL
         DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/protoc-gen-swipl)
    endblock()
else()
  message(INFO " Not building protoc-gen-swipl because BUILD_PROTOBUFS_PROTOC=OFF")
endif()
