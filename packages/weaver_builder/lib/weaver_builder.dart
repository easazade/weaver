import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/builders/auto_to_string_builder.dart';

Builder weaverBuilder(BuilderOptions options) {
  return LibraryBuilder(WeaverGenerator(), generatedExtension: 'weaver.dart');
}
