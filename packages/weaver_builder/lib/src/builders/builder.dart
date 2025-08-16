import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
// ignore: unused_import
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/builders/check_weaver_scope.dart';
import 'package:weaver_builder/src/utils/extensions.dart';
import 'package:weaver_builder/src/utils/file_header.dart';

class WeaverBuilder implements Builder {
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
      var scopeClassArgs = <FormalParameterElement>[];
      if (params.length > 1) {
        scopeClassArgs = params.sublist(1);
      }
      buffer
        ..writeln('class $scopeClassName extends Scope<$scopeArgsClassName> {') // scope class start
        ..writeln(" static const String scopeName = '$scopeName';\n");
      // ..writeln(" $scopeClassName($scopeArgsClassName args): super(name: '$scopeName', args: args);")
      // ..writeln('}');

      buffer.writeln(' $scopeClassName'); // constructor start
      var constructorArguments = scopeClassArgs
          .map((arg) {
            final type = arg.type.displayNameWithNullability!;
            final isRequired = !type.endsWith('?');
            final name = arg.displayName;

            return "${isRequired ? 'required' : ''} $type $name";
          })
          .join(',');

      if (constructorArguments.trim().isNotEmpty) {
        constructorArguments = '{ $constructorArguments }';
      }
      buffer.writeln(
        '($constructorArguments)',
      );

      final argsValue = (constructorArguments.isNotEmpty)
          ? "$scopeArgsClassName( ${scopeClassArgs.map((e) => e.displayName).join(',')})"
          : "null";
      buffer.writeln(
        ':super(name: "$scopeName", args: $argsValue);',
      ); // constructor end

      buffer.writeln('}'); // scope class end

      // create an args class for this scope if the scope requires argument to be created.
      if (scopeClassArgs.isNotEmpty) {
        buffer.writeln('class $scopeArgsClassName {');
        for (final param in scopeClassArgs) {
          final paramType = param.type.displayNameWithNullability;
          final paramName = param.displayName;
          buffer.writeln('final $paramType $paramName;');
        }

        buffer.writeln('\n$scopeArgsClassName(');
        for (final param in scopeClassArgs) {
          buffer.writeln('this.${param.displayName},');
        }
        buffer.writeln(');');

        buffer.writeln('}');
      }

      // create scope-handler class
      final scopeHandlerClassName = '${scopeName.pascalCase.replaceAll('Handler', '')}Handler';
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

      // Create extension class on Weaver
      buffer.writeln('extension ${scopeName.pascalCase}X on Weaver {');
      buffer.writeln(
        '  bool get isIn$scopeClassName => scopes.where((scope) => scope.name == "$scopeName").isNotEmpty;',
      );
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
