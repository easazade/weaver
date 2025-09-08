import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
// ignore: unused_import
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/utils/extensions.dart';
import 'package:weaver_builder/src/utils/file_header.dart';

class WeaverBuilder implements Builder {
  final _dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  static final _weaverScopeTypeChecker = const TypeChecker.typeNamed(WeaverScope);
  static final _onEnterScopeTypeChecker = const TypeChecker.typeNamed(OnEnterScope);
  static final _onLeaveScopeTypeChecker = const TypeChecker.typeNamed(OnLeaveScope);
  static final _namedDependencyTypeChecker = const TypeChecker.typeNamed(NamedDependency);

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.weaver.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();

    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final library = await resolver.libraryFor(buildStep.inputId);

    // building scope, scope-handler, scope-arg classes
    for (final classElement in library.classes) {
      if (!_weaverScopeTypeChecker.hasAnnotationOfExact(classElement)) continue;
      final weaverScopeAnnotation = _weaverScopeTypeChecker.firstAnnotationOfExact(classElement)!;

      checkForDuplicateScopeNames(library.classes);
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

      // Check if there are any @NamedDependency functions in the class

      final namedDependenciesBuffer = StringBuffer();

      for (var method in classElement.methods2) {
        if (!_namedDependencyTypeChecker.hasAnnotationOfExact(method)) {
          continue;
        }

        checkForDuplicateNamedDependencyNames(methods);
        validateSourceSyntaxOnNamedDependencyFunction(method);

        final annotation = _namedDependencyTypeChecker.firstAnnotationOfExact(method);
        final reader = ConstantReader(annotation);
        final dependencyName = reader.read('name').stringValue;
        final getterName = dependencyName.camelCase;

        final returnType = method.returnType;
        final objectType = returnType.isDartAsyncFuture
            ? (returnType as ParameterizedType).typeArguments.first.element3?.displayName
            : method.returnType.element3?.displayName;

        if (objectType?.isEmpty == true) {
          continue;
        }

        namedDependenciesBuffer.writeln(
          '''
            $objectType get $getterName {
              if(!weaverInstance.isRegistered<$objectType>(name: "$dependencyName")){
                weaverInstance.register<$objectType>(_scopeHandlerDelegate.${method.displayName}(), name: "$dependencyName");
              }

              return weaverInstance.get<$objectType>(name: "$dependencyName");
            }
          ''',
        );
      }

      // Create extension class on Weaver

      final scopeExtensionClassName = '${scopeClassName}OnWeaver';
      buffer.writeln(
        '''
        extension ${scopeExtensionClassName}AddedToWeaver on Weaver {
          $scopeExtensionClassName get ${scopeName.camelCase} => $scopeExtensionClassName(this);
        }

        class $scopeExtensionClassName {
          final Weaver weaverInstance;
          final _scopeHandlerDelegate = _AdminScope();
          
          $scopeExtensionClassName(this.weaverInstance);

          bool get inIn => weaverInstance.scopes.where((scope) => scope.name == "$scopeName").isNotEmpty;

          ${namedDependenciesBuffer.toString()}
        }
      ''',
      );

      buffer.writeln('\n'); // add space
    }

    // building named dependencies
    for (final function in library.topLevelFunctions) {
      if (!_namedDependencyTypeChecker.hasAnnotationOfExact(function)) continue;

      checkForDuplicateNamedDependencyNames(library.topLevelFunctions);
      validateSourceSyntaxOnNamedDependencyFunction(function);

      final annotation = _namedDependencyTypeChecker.firstAnnotationOfExact(function);
      final reader = ConstantReader(annotation);
      final dependencyName = reader.read('name').stringValue;
      final getterName = dependencyName.camelCase;

      final returnType = function.returnType;
      final objectType = returnType.isDartAsyncFuture
          ? (returnType as ParameterizedType).typeArguments.first.element3?.displayName
          : function.returnType.element3?.displayName;

      if (objectType?.isEmpty == true) {
        continue;
      }

      // generate extension for named object on weaver.named
      buffer.writeln(
        '''
          extension NamedDependency${getterName.pascalCase}X on WeaverNamed {
            $objectType get $getterName {
              if(!weaverInstance.isRegistered<$objectType>(name: "$dependencyName")){
                weaverInstance.register<$objectType>(${function.displayName}(), name: "$dependencyName");
              }
              return weaverInstance.get<$objectType>(name: "$dependencyName");
            }
          }
        ''',
      );
    }

    if (buffer.toString().isEmpty) {
      return;
    }

    final outputId = buildStep.inputId.changeExtension('.weaver.dart');
    var content =
        '''
          $generatedFileHeader        
          part of '${buildStep.inputId.path.split('/').last}';
          ${buffer.toString()}
        ''';

    content = _dartFormatter.tryFormat(content);
    await buildStep.writeAsString(outputId, content);
  }
}
