import 'package:build/build.dart';
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
    r'$lib$': ['weaver.gen.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final extensionsBuffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: unnecessary_string_interpolations')
      ..writeln();

    final glob = Glob('lib/**.dart');

    final importsBuffer = StringBuffer();

    await for (final input in buildStep.findAssets(glob)) {
      // Compute a package: import for this library
      // input.path is like 'lib/src/foo.dart' → import 'package:pkg/src/foo.dart';
      if (!await buildStep.resolver.isLibrary(input)) continue;
      final resolver = buildStep.resolver;
      final library = await resolver.libraryFor(input);

      final package = buildStep.inputId.package;
      final rel = input.path.substring('lib/'.length);
      final importLine = "import 'package:$package/$rel';";
      importsBuffer.writeln(importLine);

      for (final element in library.classes) {
        if (!_autoToStringChecker.hasAnnotationOfExact(element)) continue;

        final className = element.name3;
        final fields = element.fields2
            .where((f) => !f.isStatic && !f.isSynthetic)
            .toList();

        extensionsBuffer
          ..writeln('extension ${className}Auto on $className {')
          ..writeln(
            '  String stringify() => "$className(${fields.map((f) => '${f.name3}: \${${f.name3}}').join(', ')})";',
          )
          ..writeln('}')
          ..writeln();
      }
    }

    final out = AssetId(buildStep.inputId.package, 'lib/weaver.gen.dart');
    final content =
        '''${importsBuffer.toString()}

    ${extensionsBuffer.toString()}
    ''';
    await buildStep.writeAsString(out, content);
  }
}
