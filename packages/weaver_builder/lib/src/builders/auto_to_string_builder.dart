import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
// ignore: unused_import
import 'package:weaver/annotations.dart';

class AutoToStringAggregateBuilder implements Builder {
  static final _autoToStringChecker = const TypeChecker.fromRuntime(
    AutoToString,
  );

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$lib$': ['weaver.weaver.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: unnecessary_string_interpolations')
      ..writeln();

    final glob = Glob('lib/**.dart');

    await for (final input in buildStep.findAssets(glob)) {
      if (!await buildStep.resolver.isLibrary(input)) continue;
      final resolver = buildStep.resolver;
      final library = await resolver.libraryFor(input);

      for (final element in library.classes) {
        if (!_autoToStringChecker.hasAnnotationOfExact(element)) continue;

        final className = element.name3;
        final fields = element.fields2
            .where((f) => !f.isStatic && !f.isSynthetic)
            .toList();

        buffer
          ..writeln('extension ${className}Auto on $className {')
          ..writeln('  @override')
          ..writeln(
            '  String toString() => "$className(${fields.map((f) => '${f.name3}: \${this.${f.name3}}').join(', ')})";',
          )
          ..writeln('}')
          ..writeln();
      }
    }

    final out = AssetId(buildStep.inputId.package, 'lib/weaver.weaver.dart');
    await buildStep.writeAsString(out, buffer.toString());
  }
}
