import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
// ignore: unused_import
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/utils/extensions.dart';
import 'package:weaver_builder/src/utils/file_header.dart';

class WeaverScopeBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  static final _weaverScopeTypeChecker = const TypeChecker.fromRuntime(WeaverScope);
  static final _onEnterScopeTypeChecker = const TypeChecker.fromRuntime(OnEnterScope);
  static final _onLeaveScopeTypeChecker = const TypeChecker.fromRuntime(OnLeaveScope);

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$lib$': ['weaver.gen.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final codeBuffer = StringBuffer();

    final glob = Glob('lib/**.dart');

    final imports = <String>{"import 'package:weaver/weaver.dart';"};

    await for (final input in buildStep.findAssets(glob)) {
      // Compute a package: import for this library
      // input.path is like 'lib/src/foo.dart' → import 'package:pkg/src/foo.dart';
      if (!await buildStep.resolver.isLibrary(input)) continue;
      final resolver = buildStep.resolver;
      final library = await resolver.libraryFor(input);

      for (final classElement in library.classes) {
        if (!_weaverScopeTypeChecker.hasAnnotationOfExact(classElement)) continue;
        final weaverScopeAnnotation = _weaverScopeTypeChecker.firstAnnotationOfExact(classElement)!;

        _validateSourceSyntaxOnWeaverScopeClass(classElement);

        final methods = classElement.methods2;
        final onEnterScopeMethod = methods.firstWhere(
          (method) => _onEnterScopeTypeChecker.hasAnnotationOfExact(method),
        );

        final onLeaveScopeMethod = methods.firstWhere(
          (method) => _onLeaveScopeTypeChecker.hasAnnotationOfExact(method),
        );

        // process onEnterScope
        if (!_onEnterScopeTypeChecker.hasAnnotationOfExact(onEnterScopeMethod)) continue;

        final package = buildStep.inputId.package;
        final rel = input.path.substring('lib/'.length);
        final importLine = "import 'package:$package/$rel';";
        imports.add(importLine);

        final functionName = onEnterScopeMethod.displayName;
        final params = onEnterScopeMethod.formalParameters;

        _validateSourceSyntaxForOnEnterScopeMethod(params, functionName);

        final reader = ConstantReader(weaverScopeAnnotation);
        final scopeName = reader.read('name').stringValue;
        final scopeClassName = '${scopeName.pascalCase.replaceAll('Scope', '')}Scope';
        final scopeArgsClassName = params.length > 2 ? '${scopeClassName}Args' : 'void';

        // create scope class
        codeBuffer
          ..writeln('class $scopeClassName extends Scope<$scopeArgsClassName> {')
          ..writeln(" static const String scopeName = '$scopeName';\n")
          ..writeln(" $scopeClassName($scopeArgsClassName args): super(name: '$scopeName', args: args);")
          ..writeln('}');

        // create scope args class
        if (params.length > 2) {
          codeBuffer.writeln('class $scopeArgsClassName {');
          final extraParams = params.sublist(2);
          for (final param in extraParams) {
            final paramType = param.type.displayNameWithNullability;
            final paramName = param.displayName;
            codeBuffer.writeln('final $paramType $paramName;');
          }

          codeBuffer.writeln('$scopeArgsClassName({');
          for (final param in extraParams) {
            final paramName = param.displayName;
            final isRequired = !param.type.displayNameWithNullability!.endsWith('?');

            codeBuffer.writeln('${isRequired ? "required" : ""} this.$paramName,');
          }
          codeBuffer.writeln('});');

          codeBuffer.writeln('}');
        }

        // create scope-handler class

        
      }
    }

    final out = AssetId(buildStep.inputId.package, 'lib/weaver.gen.dart');
    var content =
        '''$generatedFileHeader

${imports.join('\n')}

${codeBuffer.toString()}
    ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(out, content);
  }

  /// Checks if the input source code is valid and as expected. Throws a [InvalidGenerationSource] if otherwise.
  void _validateSourceSyntaxForOnEnterScopeMethod(List<FormalParameterElement> params, String functionName) {
    if (params.length < 2) {
      throw InvalidGenerationSource(
        'handler function annotated with @WeaverScope should have at least 2 parameters "Weaver" & "WeaverState". '
        'eg: $functionName(Weaver weaver, WeaverState state, ...)',
      );
    }

    final weaverParam = params[0];
    final weaverParamType = weaverParam.type.element3?.displayName;
    if (weaverParamType != 'Weaver') {
      throw InvalidGenerationSource(
        'First parameter of the scope handler function should be of type "Weaver" not "$weaverParamType". '
        'eg: $functionName(Weaver weaver, WeaverState state, ...)',
      );
    }
    final stateParam = params[1];
    final stateParamType = stateParam.type.element3?.displayName;
    if (stateParamType != 'ScopeState') {
      throw InvalidGenerationSource(
        'Second parameter of the scope handler function should be of type "ScopeState" not "$stateParamType". '
        'eg: $functionName(Weaver weaver, WeaverState state, ...)',
      );
    }

    for (final param in params) {
      if (!param.isPositional) {
        throw InvalidGenerationSource(
          'Handler function can only have positional parameters. \n'
          'Correct ✅: $functionName(Weaver weaver, WeaverState state, String arg1, int, arg2, ...) \n'
          'Incorrect ❌: $functionName({Weaver weaver, WeaverState state, String arg1, int, arg2, ...})',
        );
      }
    }
  }

  /// Checks if the input source code for WeaverScope annotated class is valid and as expected.
  /// Throws a [InvalidGenerationSource] if otherwise.
  void _validateSourceSyntaxOnWeaverScopeClass(ClassElement2 classElement) {
    final methods = classElement.methods2;
    final onEnterScopeMethod = methods.firstWhereOrNull(
      (method) => _onEnterScopeTypeChecker.hasAnnotationOfExact(method),
    );

    final onLeaveScopeMethod = methods.firstWhereOrNull(
      (method) => _onLeaveScopeTypeChecker.hasAnnotationOfExact(method),
    );

    if (onEnterScopeMethod == null || onLeaveScopeMethod == null) {
      throw InvalidGenerationSource(
        '''-------------------------------------------------------------------------------------
scope classes annotated with @WeaverScope are required to have methods annotated with 
@OnEnterScope and @OnLeaveScope to handle dependencies when entering and leaving the scope

Example:

@WeaverScope(name: 'my-scope')
class MyScope {

  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver, ScopeState state, String arg1, int arg2) async {
    weaver.register(MyDependency(arg1, arg2));
  }

  @OnLeaveScope()
  Future<void> onLeaveScope(Weaver weaver, ScopeState state) async {
    weaver.unregister<MyDependency>();
  }
}
-------------------------------------------------------------------------------------
            ''',
      );
    }
  }
}
