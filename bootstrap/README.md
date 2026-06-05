# Bootstrap for the protoc plugin

## This documentation is somewhat out of date

The documentation has been fully updated to reflect how
`cmake -DBUILD_PROTOBUFS_PROTOC=ON` works.

## If the bootstrap fails

The most likely cause of the bootstrap failing is because the protobuf
specification has added some fields. One way of figuring out the
problem is by un-commenting the line `:- debug(dcg_trace)` in
`parse_descriptor_proto_dump.pl`.

As an example, you might get these messages:
```
ERROR: ... .google.protobuf.FieldOptions `field_and_type=17' does not exist
ERROR: ... .google.protobuf.ExtensionRangeOptions `field_and_type=2' does not exist
```

The easiest way of handling these to look for `FieldOptions` or
`ExtensionRangeOptions` in the `*_pb.pl` files
`gen_pb/google/protobuf/**`, then copy the various
`protobufs:proto_meta_*` facts and make the appropriate changes (this
should be fairly obvious from looking at the `*.proto` files that
you've downloaded from github. (There's probably a better way of doing
this; I know I didn't create the `*_pb.pl` files by hand but I've
forgotten how I did it ... perhaps the answer is elsewhere in the
`README`s.)

TODO: add some text about updating the `expand_*` predicates in
descriptor_proto_expand.pl and protoc-gen-swipl.

## How to migrate to a new version of protoc

If there have been no changes to `descriptor.proto` and
`plugin.proto`, then merely change the `PROTOC_VERSION`
values in `CMakeList.txt`.

Note that the bootstrap automatically downloads files (including the
`protoc` binary) from `github` - you set the `protoc` version in the
Cmake variable `PROTOC_VERSION`, which is set in `../CMakeLists.txt`.


## Version information

The latest bootstrap was generated from protobufs v34.0
(https://github.com/protocolbuffers/protobuf/releases/tag/v34.0)
downloaded from
https://github.com/protocolbuffers/protobuf/releases/download/v34.0/protobuf-34.0.zip
and
https://github.com/protocolbuffers/protobuf/releases/download/v34.0/protoc-34.0-linux-x86_64.zip
(the `protobuf-34.0.tar.gz` file has the same contents as the
`protobuf-34.0.zip` file).

The `protoc` version is in the Cmake variable `PROTOC_VERSION`, which
is set in `../CMakeLists.txt`.

The original bootstrap used files from https://github.com/protocolbuffers/protobuf
dated 12 Oct 2021 (commit `39013ab238a152b1794080b369f8c6648ab8104b`)
and the original bootstrap was generated with `protoc` version 3.6.1.

<!-- As of June 2024 (`protoc` 3.21.12), the only changes to -->
<!-- `descriptor.proto` are some comments and the addition of the field -->
<!-- `unverified_lazy`; `plugin.proto` hasn't changed. -->

## Installing protobuf (on Ubuntu)

You can use the Ubuntu package `protobuf-compiler` (this has been
tested with package 3.21.12-3, dated 8 Apr 2023) or you can use the
download files (mentioned above) or you can clone from
https://github.com/protocolbuffers/protobuf and build using the
instructions in `protobuf/src/README.md`. For the `./configure`
command you may wish to use `./configure --prefix=$HOME/.local` and
`make -j4` (where "4" should be replaced by the number of cores on
your machine).

There are some additional notes on this in the `Makefile`.

TODO: These notes reflect an older stage of the bootstrap process.
Both the notes and the Makefile need to be cleaned up, to remove stuff
that's no longer needed.

NOTE: the Prolog plugin outputs an error if there is a field it
doesn't recognize. This is to catch the unlikely event that the
`.proto` specification has changed by adding something which changes
the meaning of existing fields. However, Google has enormous amounts
of code that depend on protobufs, so all changes are very likely to be
backwards compatible.

## Overview of the original bootstrap process

These notes are probably a bit wrong, missing some things, and
duplicating others. See also `gen_pb/README.md` and `bootstrap.sh`.

The original bootstrap was done by running `protoc --decode` on the
files in `descriptor.proto` and `compiler/plugin.proto` (from
`https://github.com/protocolbuffers/protobuf`), producing
"*.proto.wiredump" files in (`gen_pb/google/protobuf/**`):
```
export PATH=/path/to/protoc/bin:$PATH
make -C /path/to/packages/protobufs/bootstrap check_vars
```

These were then parsed by a simple DCG in
`parse_descriptor_proto_dump.pl` to produce the ".proto.parse"
files. The term expansion logic is in `descriptor_proto_expand.pl`,
which was then copied to `protoc-gen-swipl`.  At this point,
`gen_pb/google/protobuf/descriptor_pb.pl` and
`gen_pb/google/protobuf/compiler/plugin_pb.pl` could be generated, and
the original bootstrap code was no longer needed, and the ".wiredump"
files were deleted.

If for some reason you need to redo the bootstrap, you'll very likely
need to modify the simple parser - the ".wiredump" files were deleted
because I didn't want to keep updating the parser as new features are
added to protobufs.

The tests are fairly minimal. For additional testing, see directory `interop`.


## descriptor.proto and friends

Naming conventions:

| x_pb.pl      | generated by `protoc` from x.proto (for Prolog)                      |
| x_pb2.py     | generated by `protoc` from x.proto (for Python)                      |
| x.pb.{h,cc}  | generated by `protoc` from x.proto (for C++)                         |
| x.proto      | protobuf definition: used as input to `protoc`                       |
| x.proto.wire | wire-format encoding of data (e.g., produced by SerializeToString()) |
| x.proto.wire | `protoc --descriptor_set_out=x.proto.wire`                  |
| x.proto.wiredump | readable form of x.wire, using `protoc --decode` and the appropriate .proto file |
| x.proto.segment | `swipl descriptor_proto.pl <x.proto.wire >x.proto.segment` Prolog term that contains a segmentation of the data in a .wire file (see also x.wiredump) |
| x.proto.parse | Output from `parse_descriptor_proto_dump.pl`, which is hand-edited into `descriptor_proto.pl` (`descriptor_proto/1`).  |
| x.proto.wirerawdump | (not used) readable from of x.wire, using `protoc --decode_raw` (no .proto file) |

`plugin.proto` and `descriptor.proto`  encode all `.proto` files created by
the protobuf compiler (`protoc`). Their meta-data have been bootstrapped into
`gen_pb/plugin_pb.pl` and
`gen_pb/descriptor_pb.pl`.

* `descriptor.proto.wire` contains a protobuf encoding of
  `descriptor.proto`; it is generated by
  `protoc --descriptor_set_out=descriptor.proto.wire`
* `descriptor.proto.wiredump` is generated by `protoc
  --decode=FileDescriptorSet descriptor.proto.wire`
  It is included here, to avoid a submodule dependency on
  git@github.com:protocolbuffers/protobuf.git
* `parse_descriptor_proto_dump.pl` is used to process `descriptor.proto.wiredump`
  into a Prolog term.
* `descriptor_proto.pl` is the term created by `parse_descriptor_proto_dump.pl`,
  in the clause `descriptor_proto/1`.
* `descriptor.proto.segment` is the "golden" output from rule `descriptor.segment`.
  TODO: delete this file.

TODO: use `protobuf\_segment\_message/2` to process
`descriptor.proto.wire` and any other `descriptor\_set\_out`, and then
generate Prolog code for easy handling of protobufs.

## protoc plugin

We can run a `protoc` plugin by having an executable named
`protoc-gen-swipl` that is in the `PATH`, which reads a
`CodeGeneratorRequest` from stdin (defined in
`src/protobuf/src/google/protobuf/compiler/plugin.proto`) and outputs
to stdout a `CodeGeneratorResponse`.
The plugin is specified with the `--plugin=protoc-gen-swipl=...`
option to `protoc` (you will also need to set some `-I` options,
and specify the output using `--swipl_out`).

If you make an incompatible change to `protoc-gen-swipl`, you should
increment the version and also `protobufs:verify_version/0`.  (Also
`descriptor_proto.pl`, which is mostly obsolete.)

See also
[https://protobuf.dev/programming-guides/field_presence/](Application Note: Field Presence) and
[https://github.com/protocolbuffers/protobuf/blob/main/docs/implementing_proto3_presence.md](How To Implement Field Presence for Proto3).
