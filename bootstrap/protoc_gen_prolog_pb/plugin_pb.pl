% -*- mode: prolog coding:utf-8 -*-

% This file was generated by protoc-gen-swipl
% as a plugin from protoc (the Protobuf compiler)

:-module(plugin_pb,[]).
:-encoding(utf8).
:-multifile protobufs:protoc_gen_swipl_version/2.
protobufs:protoc_gen_swipl_version(plugin_pb,[0,9]).
swi_prolog_version('8.3.27-2-g1bd6451e5-DIRTY').
protoc_version('3.17.1.').
prototoc_gen_swipl_args([]).
protoc_run_time('2021-07-13T17:25:26+0000', '2021-07-13T10:25:26-0700').
file_to_generate(["plugin.proto"]).

:- multifile
    protobufs:proto_meta_normalize/2,           %   protobufs:proto_meta_normalize(Unnormalized, Normalized),
    protobufs:proto_meta_package/3,             %   protobufs:proto_meta_package(Package, FileName, Options),
    protobufs:proto_meta_message_type/3,        %   protobufs:proto_meta_message_type(       Fqn,     Package, Name),
    protobufs:proto_meta_field_name/4,          %   protobufs:proto_meta_field_name(         Fqn,     FieldNumber, FieldName, FqnName),
    protobufs:proto_meta_field_json_name/2,     %   protobufs:proto_meta_field_json_name(    FqnName, JsonName),
    protobufs:proto_meta_field_label/2,         %   protobufs:proto_meta_field_label(        FqnName, LabelRepeatOptional) % LABEL_OPTIONAL, LABEL_REQUIRED, LABEL_REPEATED,
    protobufs:proto_meta_field_type/2,          %   protobufs:proto_meta_field_type(         FqnName, Type) % TYPE_INT32, TYPE_MESSAGE, etc,
    protobufs:proto_meta_field_type_name/2,     %   protobufs:proto_meta_field_type_name(    FqnName, TypeName),
    protobufs:proto_meta_field_default_value/2, %   protobufs:proto_meta_field_default_value(FqnName, DefaultValue),
    protobufs:proto_meta_field_option_packed/1, %   protobufs:proto_meta_field_option_packed(FqnName),
    protobufs:proto_meta_enum_type/3,           %   protobufs:proto_meta_enum_type(          FqnName, Fqn, Name),
    protobufs:proto_meta_enum_value/3.          %   protobufs:proto_meta_enum_value(         FqnName, Name, Number)

% Generating proto_meta_... facts:
  % compiler_version: '.google.protobuf.compiler.Version'{major:3,minor:17,patch:1,suffix:""}
  % file_to_generate: ["plugin.proto"]
  % parameter: ""
  % Skipping file "google/protobuf/descriptor.proto"
  % Processing file "plugin.proto"
  %  -- package("google.protobuf.compiler") name("plugin.proto") dependency(["google/protobuf/descriptor.proto"])
    protobufs:proto_meta_package('.google.protobuf.compiler','plugin.proto','.google.protobuf.FileOptions'{cc_enable_arenas:true,cc_generic_services:false,csharp_namespace:"",deprecated:false,go_package:"google.golang.org/protobuf/types/pluginpb",java_generate_equals_and_hash:false,java_generic_services:false,java_multiple_files:false,java_outer_classname:"PluginProtos",java_package:"com.google.protobuf.compiler",java_string_check_utf8:false,objc_class_prefix:"",optimize_for:"SPEED",php_class_prefix:"",php_generic_services:false,php_metadata_namespace:"",php_namespace:"",py_generic_services:false,ruby_package:"",swift_prefix:"",uninterpreted_option:[]}).
    protobufs:proto_meta_normalize('.google.protobuf.compiler.Version','.google.protobuf.compiler.Version').
    protobufs:proto_meta_normalize('google.protobuf.compiler.Version','.google.protobuf.compiler.Version').
    protobufs:proto_meta_message_type('.google.protobuf.compiler.Version','.google.protobuf.compiler','Version').
    protobufs:proto_meta_field_name('.google.protobuf.compiler.Version',1,major,'.google.protobuf.compiler.Version.major').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.Version.major',major).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.Version.major','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.Version.major','TYPE_INT32').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.Version.major','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.Version.major',0).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.Version',2,minor,'.google.protobuf.compiler.Version.minor').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.Version.minor',minor).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.Version.minor','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.Version.minor','TYPE_INT32').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.Version.minor','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.Version.minor',0).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.Version',3,patch,'.google.protobuf.compiler.Version.patch').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.Version.patch',patch).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.Version.patch','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.Version.patch','TYPE_INT32').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.Version.patch','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.Version.patch',0).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.Version',4,suffix,'.google.protobuf.compiler.Version.suffix').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.Version.suffix',suffix).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.Version.suffix','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.Version.suffix','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.Version.suffix','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.Version.suffix',"").
    protobufs:proto_meta_normalize('.google.protobuf.compiler.CodeGeneratorRequest','.google.protobuf.compiler.CodeGeneratorRequest').
    protobufs:proto_meta_normalize('google.protobuf.compiler.CodeGeneratorRequest','.google.protobuf.compiler.CodeGeneratorRequest').
    protobufs:proto_meta_message_type('.google.protobuf.compiler.CodeGeneratorRequest','.google.protobuf.compiler','CodeGeneratorRequest').
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorRequest',1,file_to_generate,'.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate',fileToGenerate).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate','LABEL_REPEATED').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorRequest.file_to_generate',[]).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorRequest',2,parameter,'.google.protobuf.compiler.CodeGeneratorRequest.parameter').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorRequest.parameter',parameter).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorRequest.parameter','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorRequest.parameter','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorRequest.parameter','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorRequest.parameter',"").
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorRequest',15,proto_file,'.google.protobuf.compiler.CodeGeneratorRequest.proto_file').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorRequest.proto_file',protoFile).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorRequest.proto_file','LABEL_REPEATED').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorRequest.proto_file','TYPE_MESSAGE').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorRequest.proto_file','.google.protobuf.FileDescriptorProto').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorRequest.proto_file',[]).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorRequest',3,compiler_version,'.google.protobuf.compiler.CodeGeneratorRequest.compiler_version').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorRequest.compiler_version',compilerVersion).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorRequest.compiler_version','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorRequest.compiler_version','TYPE_MESSAGE').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorRequest.compiler_version','.google.protobuf.compiler.Version').
    protobufs:proto_meta_normalize('.google.protobuf.compiler.CodeGeneratorResponse','.google.protobuf.compiler.CodeGeneratorResponse').
    protobufs:proto_meta_normalize('google.protobuf.compiler.CodeGeneratorResponse','.google.protobuf.compiler.CodeGeneratorResponse').
    protobufs:proto_meta_message_type('.google.protobuf.compiler.CodeGeneratorResponse','.google.protobuf.compiler','CodeGeneratorResponse').
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse',1,error,'.google.protobuf.compiler.CodeGeneratorResponse.error').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.error',error).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.error','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.error','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.error','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.error',"").
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse',2,supported_features,'.google.protobuf.compiler.CodeGeneratorResponse.supported_features').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.supported_features',supportedFeatures).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.supported_features','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.supported_features','TYPE_UINT64').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.supported_features','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.supported_features',0).
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse',15,file,'.google.protobuf.compiler.CodeGeneratorResponse.file').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.file',file).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.file','LABEL_REPEATED').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.file','TYPE_MESSAGE').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.file','.google.protobuf.compiler.CodeGeneratorResponse.File').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.file',[]).
    protobufs:proto_meta_normalize('.google.protobuf.compiler.CodeGeneratorResponse.File','.google.protobuf.compiler.CodeGeneratorResponse.File').
    protobufs:proto_meta_normalize('google.protobuf.compiler.CodeGeneratorResponse.File','.google.protobuf.compiler.CodeGeneratorResponse.File').
    protobufs:proto_meta_message_type('.google.protobuf.compiler.CodeGeneratorResponse.File','.google.protobuf.compiler.CodeGeneratorResponse','File').
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse.File',1,name,'.google.protobuf.compiler.CodeGeneratorResponse.File.name').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.File.name',name).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.File.name','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.File.name','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.File.name','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.File.name',"").
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse.File',2,insertion_point,'.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point',insertionPoint).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.File.insertion_point',"").
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse.File',15,content,'.google.protobuf.compiler.CodeGeneratorResponse.File.content').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.File.content',content).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.File.content','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.File.content','TYPE_STRING').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.File.content','').
    protobufs:proto_meta_field_default_value('.google.protobuf.compiler.CodeGeneratorResponse.File.content',"").
    protobufs:proto_meta_field_name('.google.protobuf.compiler.CodeGeneratorResponse.File',16,generated_code_info,'.google.protobuf.compiler.CodeGeneratorResponse.File.generated_code_info').
    protobufs:proto_meta_field_json_name('.google.protobuf.compiler.CodeGeneratorResponse.File.generated_code_info',generatedCodeInfo).
    protobufs:proto_meta_field_label('.google.protobuf.compiler.CodeGeneratorResponse.File.generated_code_info','LABEL_OPTIONAL').
    protobufs:proto_meta_field_type('.google.protobuf.compiler.CodeGeneratorResponse.File.generated_code_info','TYPE_MESSAGE').
    protobufs:proto_meta_field_type_name('.google.protobuf.compiler.CodeGeneratorResponse.File.generated_code_info','.google.protobuf.GeneratedCodeInfo').
    protobufs:proto_meta_enum_type('.google.protobuf.compiler.CodeGeneratorResponse.Feature','.google.protobuf.compiler.CodeGeneratorResponse','Feature').
    protobufs:proto_meta_enum_value('.google.protobuf.compiler.CodeGeneratorResponse.Feature','FEATURE_NONE',0).
    protobufs:proto_meta_enum_value('.google.protobuf.compiler.CodeGeneratorResponse.Feature','FEATURE_PROTO3_OPTIONAL',1).

% End of generated proto_meta_... facts.

end_of_file.
