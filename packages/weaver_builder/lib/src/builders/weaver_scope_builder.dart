import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
// ignore: unused_import
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/builders/check_weaver_scope.dart';
import 'package:weaver_builder/src/utils/extensions.dart';
import 'package:weaver_builder/src/utils/file_header.dart';

class WeaverScopeBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  static final _weaverScopeTypeChecker = const TypeChecker.fromRuntime(WeaverScope);
  static final _onEnterScopeTypeChecker = const TypeChecker.fromRuntime(OnEnterScope);
  static final _onLeaveScopeTypeChecker = const TypeChecker.fromRuntime(OnLeaveScope);

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.weaver.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    // Compute a package: import for this library
    // input.path is like 'lib/src/foo.dart' → import 'package:pkg/src/foo.dart';
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final library = await resolver.libraryFor(buildStep.inputId);

    for (final classElement in library.classes) {
      if (!_weaverScopeTypeChecker.hasAnnotationOfExact(classElement)) return;
      final weaverScopeAnnotation = _weaverScopeTypeChecker.firstAnnotationOfExact(classElement)!;

      validateSourceSyntaxOnWeaverScopeClass(classElement);

      final methods = classElement.methods2;
      final onEnterScopeMethod = methods.firstWhere((method) => _onEnterScopeTypeChecker.hasAnnotationOfExact(method));
      final onLeaveScopeMethod = methods.firstWhere((method) => _onLeaveScopeTypeChecker.hasAnnotationOfExact(method));
      final params = onEnterScopeMethod.formalParameters;

      final reader = ConstantReader(weaverScopeAnnotation);
      final scopeName = reader.read('name').stringValue;
      final scopeClassName = '${scopeName.pascalCase.replaceAll('Scope', '')}Scope';
      final scopeArgsClassName = params.length > 1 ? '${scopeClassName}Args' : 'void';

      // create scope class
      buffer
        ..writeln('class $scopeClassName extends Scope<$scopeArgsClassName> {')
        ..writeln(" static const String scopeName = '$scopeName';\n")
        ..writeln(" $scopeClassName($scopeArgsClassName args): super(name: '$scopeName', args: args);")
        ..writeln('}');

      // create scope args class
      if (params.length > 1) {
        buffer.writeln('class $scopeArgsClassName {');
        final extraParams = params.sublist(1);
        for (final param in extraParams) {
          final paramType = param.type.displayNameWithNullability;
          final paramName = param.displayName;
          buffer.writeln('final $paramType $paramName;');
        }

        buffer.writeln('$scopeArgsClassName({');
        for (final param in extraParams) {
          final paramName = param.displayName;
          final isRequired = !param.type.displayNameWithNullability!.endsWith('?');

          buffer.writeln('${isRequired ? "required" : ""} this.$paramName,');
        }

        buffer.writeln('});');

        buffer.writeln('}');
      }

      // create scope-handler class
      final scopeHandlerClassName = '${classElement.displayName.pascalCase.replaceAll('Handler', '')}Handler';
      buffer
        ..writeln('class $scopeHandlerClassName extends ScopeHandler<$scopeArgsClassName> {')
        ..writeln('final _scopeHandlerDelegate = ${classElement.displayName}();\n');

      buffer
        ..writeln('@override')
        ..writeln("String get scopeName => '$scopeName';\n");

      buffer
        ..writeln('@override')
        ..writeln('Future<void> onLeaveScope(Weaver weaver) async {')
        ..writeln(
          ' await _scopeHandlerDelegate.${onLeaveScopeMethod.displayName}(weaver);',
        )
        ..writeln('}\n');

      buffer
        ..writeln('@override')
        ..writeln('Future<void> onEnterScope(Weaver weaver, $scopeArgsClassName args) async {');
      buffer.writeln(
        'await _scopeHandlerDelegate.${onEnterScopeMethod.displayName}(weaver, ${onEnterScopeMethod.formalParameters.sublist(1).map((param) => 'args.${param.displayName}').join(',')});',
      );
      buffer.writeln('  }');
      buffer.writeln('}');
    }

    // add part of directive

    final outputId = buildStep.inputId.changeExtension('.weaver.dart');
    var content =
        '''$generatedFileHeader
        
part of '${buildStep.inputId.path.split('/').last}';

${buffer.toString()}
    ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
