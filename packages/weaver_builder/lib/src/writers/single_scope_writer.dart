import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/type_checkers.dart';
import 'package:weaver_builder/src/utils/extensions.dart';

void writeClassesForScopes({
  required StringBuffer buffer,
  required LibraryElement library,
}) {
  for (final classElement in library.classes) {
    if (!weaverScopeTypeChecker.hasAnnotationOfExact(classElement)) continue;
    checkForDuplicateScopeNames(library.classes);
    validateSourceSyntaxOnWeaverScopeClass(classElement);

    final weaverScopeAnnotation = weaverScopeTypeChecker.firstAnnotationOfExact(classElement)!;

    final methods = classElement.methods;
    final onEnterScopeMethod = methods.firstWhere((method) => onEnterScopeTypeChecker.hasAnnotationOfExact(method));
    final onLeaveScopeMethod =
        methods.firstWhereOrNull((method) => onLeaveScopeTypeChecker.hasAnnotationOfExact(method));
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
    var constructorArguments = scopeClassArgs.map((arg) {
      final type = arg.type.displayNameWithNullability!;
      final isRequired = !type.endsWith('?');
      final name = arg.displayName;

      return "${isRequired ? 'required' : ''} $type $name";
    }).join(',');

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

    // Check if there are any @NamedDependency functions in the scope-handler class first
    // registering and unregistering of NamedDependencies need to be handled automatically
    // also a quick access extension function needs to be created for it

    final namedDependenciesQuickAccessMethodsPart = StringBuffer();
    final namedDependenciesAutoRegisterPart = StringBuffer();
    final namedDependenciesAutoUnRegisterPart = StringBuffer();

    for (var method in classElement.methods) {
      if (!namedDependencyTypeChecker.hasAnnotationOfExact(method)) {
        continue;
      }

      checkForDuplicateNamedDependencyNames(methods);
      validateSourceSyntaxOnNamedDependencyFunction(method);

      final annotation = namedDependencyTypeChecker.firstAnnotationOfExact(method);
      final reader = ConstantReader(annotation);
      final dependencyName = reader.read('name').stringValue;
      final enabledAutoDispose = reader.read('autoDispose').boolValue;
      final getterName = dependencyName.camelCase;

      final returnType = method.returnType;
      final objectType = returnType.isDartAsyncFuture
          ? (returnType as ParameterizedType).typeArguments.first.element?.displayName
          : method.returnType.element?.displayName;

      if (objectType?.isEmpty == true) {
        continue;
      }

      namedDependenciesAutoRegisterPart.writeln(
        'weaverInstance.register<$objectType>(_scopeHandlerDelegate.${method.displayName}(), name: "$dependencyName");',
      );

      if (enabledAutoDispose) {
        namedDependenciesAutoUnRegisterPart.writeln('weaverInstance.unregister<$objectType>(name: "$dependencyName");');
      }

      namedDependenciesQuickAccessMethodsPart.writeln(
        '$objectType get $getterName => weaverInstance.get<$objectType>(name: "$dependencyName");',
      );
    }

    // create scope-handler class
    final scopeHandlerClassName =
        '${scopeName.pascalCase.replaceAll('Scope', '').replaceAll('Handler', '')}ScopeHandler';

    buffer.writeln('''
        class $scopeHandlerClassName extends SingleScopeHandler<$scopeArgsClassName> {
        $scopeHandlerClassName(super.weaver, {super.changeScopeStream});

        final _scopeHandlerDelegate = ${classElement.displayName}();

        @override
        String get scopeName => '$scopeName';

        @override
        Future<void> onEnterScope(Weaver weaver, $scopeArgsClassName args) async {
          ${namedDependenciesAutoRegisterPart.toString()}
          await _scopeHandlerDelegate.${onEnterScopeMethod.displayName}(weaverInstance, ${onEnterScopeMethod.formalParameters.sublist(1).map((param) => 'args.${param.displayName}').join(',')});
        }  
      ''');

    if (onLeaveScopeMethod != null) {
      buffer.writeln('''
          @override
          Future<void> onLeaveScope(Weaver weaver) async {
            await _scopeHandlerDelegate.${onLeaveScopeMethod.displayName}(weaverInstance);
            ${namedDependenciesAutoUnRegisterPart.toString()}
          }\n 
        ''');
    } else {
      buffer.writeln('''
          @override
          Future<void> onLeaveScope(Weaver weaver) async {
            // no methods are annotated with @OnLeaveScope in the scope handler delegate for 
            // custom disposal and unregistering of the dependencies registered for this scope
            (weaver as ScopeHandlerWeaverProxy).unregisterDependenciesRegisteredByThisProxy();
            ${namedDependenciesAutoUnRegisterPart.toString()}
          }
        ''');
    }

    buffer.writeln('}'); // end of scope handler class

    // Create extension class on Weaver

    final scopeExtensionClassName = '${scopeClassName}OnWeaver';
    buffer.writeln(
      '''
        extension ${scopeExtensionClassName}AddedToWeaver on Weaver {
          $scopeExtensionClassName get ${scopeClassName.camelCase} => $scopeExtensionClassName(ScopeHandlerWeaverProxy(this));
        }

        class $scopeExtensionClassName {
          final ScopeHandlerWeaverProxy weaverInstance;

          final _scopeHandlerDelegate = ${classElement.displayName}();
          
          $scopeExtensionClassName(this.weaverInstance);

          bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "$scopeName").isNotEmpty;

          ${namedDependenciesQuickAccessMethodsPart.toString()}

          Stream<Scope<$scopeArgsClassName>?> get stream {
            final matches = weaverInstance.handlers.whereType<$scopeHandlerClassName>();
            if (matches.isEmpty) {
              throw WeaverException(
                'Tried to listen on stream of $scopeClassName without a handler class registered. '
                'Please register an instance of $scopeHandlerClassName first before trying to listen to its stream',
              );
            }

            final handler = matches.first;
            return handler.stream;
          }
        }
      ''',
    );

    buffer.writeln('\n'); // add space
  }
}
