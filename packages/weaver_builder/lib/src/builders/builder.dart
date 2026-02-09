import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:weaver_builder/src/utils/extensions.dart';
import 'package:weaver_builder/src/utils/file_header.dart';
import 'package:weaver_builder/src/writers/named_dependency_writer.dart';
import 'package:weaver_builder/src/writers/sessions_writer.dart';
import 'package:weaver_builder/src/writers/single_scope_writer.dart';
import 'package:weaver_builder/src/writers/switch_scope_writer.dart';

class WeaverBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.weaver.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Explicitly read the input file to ensure build runner tracks it as a dependency
    await buildStep.readAsString(buildStep.inputId);
    
    final buffer = StringBuffer();

    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final library = await resolver.libraryFor(buildStep.inputId);

    // Generating scope, scope-handler, scope-arg, scope-on-weaver, extension classes
    writeClassesForScopes(buffer: buffer, library: library);

    // Generating scope, scope-handler, scope-arg, scope-on-weaver, extension classes
    writeClassesForSwitchScopes(buffer: buffer, library: library);

    // Generating named dependencies
    writeNamedDependencies(buffer: buffer, library: library);

    // Generating sessions
    writeSessions(buffer: buffer, library: library);

    if (buffer.toString().isEmpty) {
      return;
    }

    final outputId = buildStep.inputId.changeExtension('.weaver.dart');
    var content = '''
          $generatedFileHeader        
          part of '${buildStep.inputId.path.split('/').last}';
          ${buffer.toString()}
        ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
