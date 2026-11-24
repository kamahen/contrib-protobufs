cmake_minimum_required(VERSION 3.10)
project(swipl-protobufs)

include("../cmake/PrologPackage.cmake")

# TODO: find_program(PKG_CONFIG_EXE pkg_config)
# TODO: https://cmake.org/cmake/help/latest/module/FindPkgConfig.html
# TODO: requires cmake 3.31:
#       https://cmake.org/cmake/help/latest/command/cmake_pkg_config.html

# download protoc from
# https://github.com/protocolbuffers/protobuf/releases?page=9#release-v24.4
set(PROTOC_VERSION "24.4")

add_subdirectory(bootstrap)

AC_CHECK_HEADERS(sys/types.h)

configure_file(config.h.cmake config.h)

swipl_plugin(
    protobufs
    C_SOURCES protobufs.c
    PL_LIBS protobufs.pl)

# The following swipl_plugin() doesn't work because protoc-gen-swipl
# has to be marked executable. So, create this "swipl_plugin" using
# install_src().
#    swipl_plugin(
#        protoc-gen-swipl
#        PL_LIB_SUBDIR protobufs
#        PL_LIBS bootstrap/protoc-gen-swipl)

# string(REPLACE "/" "_" src_target "plugin_${name}_${sd}_pl_libs")
install_src(plugin_protoc-gen-swipl_protobufs_pl_libs
            PROGRAMS bootstrap/protoc-gen-swipl
            DESTINATION ${SWIPL_INSTALL_LIBRARY}/protobufs)
add_index(protobufs bootstrap/protoc-gen-swipl)

swipl_plugin(
    protoc-gen-swipl-subdir
    PL_LIB_SUBDIR protobufs/gen_pb/google/protobuf
    PL_LIBS       bootstrap/gen_pb/google/protobuf/descriptor_pb.pl)

swipl_plugin(
    protoc-gen-swipl-subdir2
        PL_LIB_SUBDIR protobufs/gen_pb/google/protobuf/compiler
        PL_LIBS       bootstrap/gen_pb/google/protobuf/compiler/plugin_pb.pl)

swipl_examples(
               some_message.proto
               some_message.py
               eventually_implies.pl
               )
swipl_examples(
               demo/README.md
               demo/Makefile
               demo/foo.cpp
               demo/pb_vector.proto
               demo/vector_demo.pl
               SUBDIR demo
               )
swipl_examples(
               interop/README.md
               interop/Makefile
               interop/addressbook.proto
               interop/addressbook2.proto
               interop/addressbook.pl
               interop/test.proto
               interop/test2.proto
               interop/test2b.proto
               interop/test_read.cc
               interop/test_read.py
               interop/test_interop.pl
               interop/test_templates.pl
               interop/test_write.cc
               interop/test_write.py
               # TODO: the following should go into a subdir (see following stanza):
                 interop/google/protobuf/unittest_import.proto
                 interop/google/protobuf/unittest.proto
                 interop/google/protobuf/unittest_import_public.proto
               SUBDIR interop
              )
# TODO: the following gets an error due to target name containing a "/":
# swipl_examples(
#                interop/google/protobuf/unittest_import.proto
#                interop/google/protobuf/unittest.proto
#                interop/google/protobuf/unittest_import_public.proto
#                SUBDIR interop/google/protobuf
#               )
swipl_examples(
                bootstrap/README.md
                bootstrap/common.mk
                # The following aren't included because they're mainly
                #   for creating protoc and may disappear when the full
                #   bootstrap is operational:
                # bootstrap/descriptor_proto_expand.pl
                # bootstrap/descriptor_proto.pl
                # bootstrap/Makefile
                # bootstrap/parse_descriptor_proto_dump.pl
                # # bootstrap/gen_pb/** (subdir)
                # bootstrap/protoc-gen-swipl
                # bootstrap/tests.pl
                SUBDIR bootstrap
               )

# TODO: move tests to appropriate sub-directories
test_libs(protobufs
          TEST_FILES
              golden_message.2.3.0 golden_message.2.5.0
              eventually_implies.pl
              test_bootstrap.sh test_interop.sh test_demo.sh
              some_message.proto
              some_message.py
              test_protobufs.pl
          TEST_DIRS
              bootstrap demo interop
              )

find_program(PROG_PROTOC protoc)
find_program(PKG_CONFIG pkg-config)

# TODO: check minimal versions of protoc, python3, pip protobuf

# TODO: find_package(Python COMPONENTS Interpreter)  # Development ?
#     Python_Interpreter_FOUND    Boolean indicating whether system has the Python interpreter.
#     Python_EXECUTABLE

find_package(Python COMPONENTS Interpreter)
if(Python_Interpreter_FOUND)
  execute_process(COMMAND ${Python_EXECUTABLE} -c "from google.protobuf import descriptor_pb2"
    RESULT_VARIABLE python3_protobuf
    OUTPUT_VARIABLE python3_protobuf_output
    ERROR_QUIET)
endif()

# TODO: The protobuf tests leave stuff in the source directories
#       These can be removed by:
#           for d in interop demo bootstrap; do make -C $d clean; done
#          (also: "git clean -dxf", but that's dangerous)
if(BUILD_TESTING AND TEST_PROTOBUFS_PROTOC)
  if("${python3_protobuf}" EQUAL "0")
      # TODO: this is wrong? - remmove test_bootstrap.sh?
      add_test(NAME "${SWIPL_PKG}:bootstrap"
               COMMAND cmake -E ${CMAKE_CURRENT_SOURCE_DIR}/test_bootstrap.sh ${PROG_SWIPL} ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap)
      if(USE_GMP)
          add_test(NAME "${SWIPL_PKG}:interop"
                   COMMAND cmake -E env PROG_SWIPL=${PROG_SWIPL}
                                        CMAKE_CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
                       ${CMAKE_CURRENT_SOURCE_DIR}/test_interop.sh)
      else()
          message(WARNING "${SWIPL_PKG}:interop skipped because it needs GMP")
      endif()
      add_test(NAME "${SWIPL_PKG}:demo"
               COMMAND cmake -E ${CMAKE_CURRENT_SOURCE_DIR}/test_demo.sh ${PROG_SWIPL} ${CMAKE_CURRENT_SOURCE_DIR}/demo)
  else()
      message(WARNING "Some ${SWIPL_PKG} tests not run because of missing pkg-config, protoc, or python/protobuf")
      message(WARNING "See demo/README.md for how to set up the build and test environment")
      message(WARNING "pkg-config: ${PKG_CONFIG}")
      message(WARNING "protoc: ${PROG_PROTOC}")
      message(WARNING "python3_protobuf: ${python3_protobuf}")
  endif()
else()
  if(BUILD_TESTING)
    # message("Some ${SWIPL_PKG} tests not run because TEST_PROTOBUFS_PROTOC not set")
  endif()
endif()

pkg_doc(protobufs
        SECTION
            protobufs_overview.md
            SOURCE protobufs.pl protobufspl.tex)
