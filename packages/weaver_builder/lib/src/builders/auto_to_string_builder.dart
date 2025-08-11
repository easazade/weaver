import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver/weaver.dart';

class WeaverGenerator extends GeneratorForAnnotation<AutoToString> {
  final _fmt = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  @override
  generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        '@AutoToString can only be used on classes.',
        element: element,
      );
    }

    final cls = element;
    final fields = cls.fields2.where((f) => !f.isStatic).toList();

    final buf = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('extension ${cls.name3}Auto on ${cls.name3} {')
      ..writeln('  @override')
      ..writeln(
        '  String toString() => "${cls.name3}('
        '${fields.map((f) => '${f.name3}: \${this.${f.name3}}').join(', ')}'
        ')";',
      )
      ..writeln('}');

    return _fmt.format(buf.toString());
  }
}

// class AutoToStringBuilder extends Builder {
//   final _formatter = DartFormatter(
//     languageVersion: DartFormatter.latestLanguageVersion,
//   );

//   @override
//   FutureOr<void> build(BuildStep buildStep) async {
//     if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
//       return;
//     }

//     // Check if this file contains @WeaverMain annotation
//     Log.greenText('Start build() method');
//     final inputSource = await buildStep.readAsString(buildStep.inputId);
//     bool hasWeaverMain = inputSource.contains('@WeaverMain()');

//     Log.yellowText('Input ID: ${buildStep.inputId}');
//     // Log.yellowText('Input Source: $inputSource');

//     // Only generate the output file for the file that has @WeaverMain

//     // Collect all classes annotated with @AutoToString from the entire project

//     // Find all dart files in the project
//     final dartFiles = Glob('**/*.dart');
//     // await for (final assetId in buildStep.findAssets(dartFiles)) {
//     //   Log.whiteText('Checking if assetId: ($assetId) is a library');

//     //   if (await buildStep.resolver.isLibrary(assetId)) {
//     //     final sourceContent = await buildStep.readAsString(assetId);

//     //     // Simple regex-based parsing for classes with @AutoToString annotation
//     //     if (sourceContent.contains('@AutoToString()')) {
//     //       final lines = sourceContent.split('\n');

//     //       for (int i = 0; i < lines.length; i++) {
//     //         final line = lines[i];
//     //         if (line.trim().startsWith('@AutoToString()')) {
//     //           // Look for the class definition in the next few lines
//     //           for (int j = i + 1; j < lines.length && j < i + 5; j++) {
//     //             final classLine = lines[j].trim();
//     //             if (classLine.startsWith('class ')) {
//     //               final className = _extractClassName(classLine);
//     //               if (className != null) {
//     //                 final fields = _extractFields(sourceContent, className);
//     //                 autoToStringClasses.add(
//     //                   ClassInfo(
//     //                     className: className,
//     //                     fields: fields,
//     //                     libraryUri: assetId.uri.toString(),
//     //                   ),
//     //                 );
//     //                 break;
//     //               }
//     //             }
//     //           }
//     //         }
//     //       }
//     //     }
//     //   }
//     // }

//     // Generate the output file
//     // final generatedCode = _generateToStringFile(autoToStringClasses);
//     // final formattedCode = _formatter.format(generatedCode);

//     final outputId = buildStep.allowedOutputs.first;
//     await buildStep.writeAsString(outputId, '// ${buildStep.inputId}');
//     Log.redText('End build method');
//   }

//   @override
//   Map<String, List<String>> get buildExtensions => {
//     '.dart': ['.weaver.dart'],
//   };
// }
