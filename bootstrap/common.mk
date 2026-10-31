# Common Makefile definitions

RM=rm -f

# If running from cmake, the command sets SWIPL=${PROG_SWIPL}
#       - See also: current_prolog_flag(executable, Exe)
ifdef SWIPL
BUILD_BIN_DIR?=$(dir $(SWIPL))
else
BUILD_BIN_DIR?=$(dir $(shell which swipl))
SWIPL?=$(BUILD_BIN_DIR)swipl
endif
PATH_WITH_SWIPL?=$(realpath -s $(BUILD_BIN_DIR)):$$PATH

# Where to find descriptor.proto:
PROTOC_DOTDOT:=$(realpath -s $(dir $(shell which protoc))/..)
PROTOC_INCLUDE=$(PROTOC_DOTDOT)/include
PROTOC_LIB:=$(PROTOC_DOTDOT)/lib

# TODO: change this to the build directory:
PROTOC_GEN_PROLOG_PB=gen_pb

# If SHELL is bash, can use `type -p protoc` instead of `which protoc`
# Requires having done "make" in ~/src/protobufs:
#   PROTOC:=$(realpath -s $(HOME)/src/protobuf/src/protoc)
PROTOC:=$(shell which protoc)
# Requires having LD_LIBRARY_PATH=$(realpath ../../../../protobuf/src/.libs):
#   PROTOC:=$(realpath -s $(HOME)/src/protobuf/src/.libs/protoc)

# If using $SRC/protobuf from git@github.com:protocolbuffers/protobuf.git:
#   -I$(SRC)/protobuf/src/google/protobuf
PROTOC_I=-I. -I../demo -I../interop -I$(PROTOC_INCLUDE)

# This is essentially what GNU Make 4.2.1 uses as a built-in rule:
#   CXX=g++
#   %o: %.cpp
# 	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $^

# Don't specify -Wall -- it produces warnings from the generated *.pb.cc files
CFLAGS=-O0
CXXFLAGS=-O0

# TODO: pkg-config is slow (because of all  the absl libraries),
#       so for development do "make FAST=yes ..."
ifndef FAST
DUMMY_XXXX:=$(shell echo pkg-config can take a while ... 1>&2)
CPPFLAGS:=$(shell pkg-config --cflags protobuf)
LDFLAGS:=$(shell pkg-config --libs protobuf)
DUMMY_XXXX:=$(shell echo pkg-config done 1>&2)
else
# protoc 3.21.12, installed in $HOME/.local
CPPFLAGS:=-I$$HOME/.local/include -DNOMINMAX
LDFLAGS:=-lprotobuf -labsl_log_internal_check_op -labsl_die_if_null -labsl_log_internal_conditions -labsl_log_internal_message -labsl_examine_stack -labsl_log_internal_format -labsl_log_internal_nullguard -labsl_log_internal_structured_proto -labsl_log_internal_proto -labsl_log_internal_log_sink_set -labsl_log_sink -labsl_flags_internal -labsl_flags_marshalling -labsl_flags_reflection -labsl_flags_private_handle_accessor -labsl_flags_commandlineflag -labsl_flags_commandlineflag_internal -labsl_flags_config -labsl_flags_program_name -labsl_log_initialize -labsl_log_internal_globals -labsl_log_globals -labsl_vlog_config_internal -labsl_log_internal_fnmatch -labsl_raw_hash_set -labsl_hash -labsl_city -labsl_low_level_hash -labsl_hashtablez_sampler -labsl_random_distributions -labsl_random_seed_sequences -labsl_random_internal_entropy_pool -labsl_random_internal_randen -labsl_random_internal_randen_hwaes -labsl_random_internal_randen_hwaes_impl -labsl_random_internal_randen_slow -labsl_random_internal_platform -labsl_random_internal_seed_material -labsl_random_seed_gen_exception -labsl_statusor -labsl_status -labsl_cord -labsl_cordz_info -labsl_cord_internal -labsl_cordz_functions -labsl_exponential_biased -labsl_cordz_handle -labsl_crc_cord_state -labsl_crc32c -labsl_crc_internal -labsl_crc_cpu_detect -labsl_leak_check -labsl_strerror -labsl_str_format_internal -labsl_synchronization -labsl_graphcycles_internal -labsl_kernel_timeout_internal -labsl_stacktrace -labsl_symbolize -labsl_debugging_internal -labsl_demangle_internal -labsl_demangle_rust -labsl_decode_rust_punycode -labsl_utf8_for_code_point -labsl_malloc_internal -labsl_tracing_internal -labsl_time -labsl_civil_time -labsl_time_zone -lutf8_validity -lutf8_range -labsl_strings -labsl_strings_internal -labsl_string_view -labsl_int128 -labsl_base -lrt -labsl_spinlock_wait -labsl_throw_delegate -labsl_raw_logging_internal -labsl_log_severity
endif

PYTHON:=$(shell which python3)
