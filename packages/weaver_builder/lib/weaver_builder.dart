import 'package:build/build.dart';
import 'package:weaver_builder/src/builders/weaver_scope_builder.dart';

Builder weaverBuilder(BuilderOptions options) {
  // return LibraryBuilder(WeaverGenerator(), generatedExtension: '.weaver.dart');
  return WeaverScopeBuilder();
}
