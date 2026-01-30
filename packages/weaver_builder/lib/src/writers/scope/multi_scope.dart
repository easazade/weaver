import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/type_checkers.dart';
import 'package:weaver_builder/src/utils/extensions.dart';

void writeClassesForMultiScope({
  required StringBuffer buffer,
  required LibraryElement2 library,
  required ClassElement2 classElement,
}) {
  final weaverScopeAnnotation = weaverScopeTypeChecker.firstAnnotationOfExact(classElement)!;

  final methods = classElement.methods2;
  final onEnterScopeMethods = methods.where((method) => onEnterScopeTypeChecker.hasAnnotationOfExact(method));
  final onLeaveScopeMethod = methods.firstWhereOrNull((method) => onLeaveScopeTypeChecker.hasAnnotationOfExact(method));

  final reader = ConstantReader(weaverScopeAnnotation);
  final scopeName = reader.read('name').stringValue;
  final baseScopeClassName = '${scopeName.pascalCase.replaceAll('Scope', '')}Scope';
  final baseScopeArgsClassName = 'Base${baseScopeClassName}Args';

  // create arg class
  buffer.writeln(
    '''
      class $baseScopeArgsClassName {}
    ''',
  );

  // create scope classes
  for (var onEnterScopeMethod in onEnterScopeMethods) {
    final onEnterScopeAnnotation = onEnterScopeTypeChecker.firstAnnotationOfExact(onEnterScopeMethod);
    final reader = ConstantReader(onEnterScopeAnnotation);
    final childScopeName = reader.read('name').stringValue;
    final params = onEnterScopeMethod.formalParameters;
    final scopeArgsClassName = params.length > 1 ? '$baseScopeClassName${childScopeName.pascalCase}Args' : 'void';
    final childScopeClassName = '${scopeName.pascalCase.replaceAll('Scope', '')}${childScopeName.pascalCase}Scope';
    var scopeClassArgs = <FormalParameterElement>[];
    if (params.length > 1) {
      scopeClassArgs = params.sublist(1);
    }

    var constructorArguments = scopeClassArgs.map((arg) {
      final type = arg.type.displayNameWithNullability!;
      final isRequired = !type.endsWith('?');
      final name = arg.displayName;

      return "${isRequired ? 'required' : ''} $type $name";
    }).join(',');

    if (constructorArguments.trim().isNotEmpty) {
      constructorArguments = '{ $constructorArguments }';
    }

    final argsValue = (constructorArguments.isNotEmpty)
        ? "$scopeArgsClassName( ${scopeClassArgs.map((e) => e.displayName).join(',')})"
        : "null";

    buffer.writeln(
      '''
      class $childScopeClassName extends Scope<$scopeArgsClassName> {
        static const String scopeName = '$scopeName';

        $childScopeClassName($constructorArguments):super(name: "$scopeName", args: $argsValue);
      }
      ''',
    );

    // create an args class for this scope if the scope requires argument to be created.
    if (scopeClassArgs.isNotEmpty) {
      buffer.writeln(
        '''
          class $scopeArgsClassName extends $baseScopeArgsClassName{
          // properties
          ${scopeClassArgs.map(
          (arg) {
            final paramType = arg.type.displayNameWithNullability;
            final paramName = arg.displayName;
            return 'final $paramType $paramName;\n';
          },
        ).join('\n')}

          // constructor
          $scopeArgsClassName(
            ${scopeClassArgs.map((arg) => 'this.${arg.displayName},').join('')}
          );

          }
          ''',
      );
    }
  }

  // Check if there are any @NamedDependency functions in the scope-handler class first
  // registering and unregistering of NamedDependencies need to be handled automatically
  // also a quick access extension function needs to be created for it

  final namedDependenciesQuickAccessMethodsPart = StringBuffer();
  final namedDependenciesAutoRegisterPart = StringBuffer();
  final namedDependenciesAutoUnRegisterPart = StringBuffer();

  for (var method in classElement.methods2) {
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
        ? (returnType as ParameterizedType).typeArguments.first.element3?.displayName
        : method.returnType.element3?.displayName;

    if (objectType?.isEmpty == true) {
      continue;
    }

    namedDependenciesAutoRegisterPart.writeln(
      'weaver.register<$objectType>(_scopeHandlerDelegate.${method.displayName}(), name: "$dependencyName");',
    );

    if (enabledAutoDispose) {
      namedDependenciesAutoUnRegisterPart.writeln('weaver.unregister<$objectType>(name: "$dependencyName");');
    }

    namedDependenciesQuickAccessMethodsPart.writeln(
      '$objectType get $getterName => weaverInstance.get<$objectType>(name: "$dependencyName");',
    );
  }

  // create scope-handler class
  final scopeHandlerClassName = '${scopeName.pascalCase.replaceAll('Scope', '').replaceAll('Handler', '')}ScopeHandler';

  buffer.writeln('''
        class $scopeHandlerClassName extends MultiScopeHandler<$baseScopeArgsClassName> {
        $scopeHandlerClassName(super.weaver);

        final _scopeHandlerDelegate = ${classElement.displayName}();

        @override
        String get scopeName => '$scopeName';

        @override
        Future<void> onEnterScope(Weaver weaver, $baseScopeArgsClassName args) async {
          ${namedDependenciesAutoRegisterPart.toString()}
          //TODO ?????
        }
      ''');

  if (onLeaveScopeMethod != null) {
    buffer.writeln('''
          @override
          Future<void> onLeaveScope(Weaver weaver) async {
            await _scopeHandlerDelegate.${onLeaveScopeMethod.displayName}(weaver);
            ${namedDependenciesAutoUnRegisterPart.toString()}
          }\n
        ''');
  } else {
    buffer.writeln('''
          @override
          Future<void> onLeaveScope(Weaver weaver) async {
            // no methods are annotated with @OnLeaveScope in the scope handler delegate for
            // custom disposal and unregistering of the dependencies registered for this scope
            (weaver as ScopeHandlerWeaverProxy).unregisterDependencies();
            ${namedDependenciesAutoUnRegisterPart.toString()}
          }
        ''');
  }

  buffer.writeln('}'); // end of scope handler class

  // Create extension class on Weaver

  final scopeExtensionClassName = '${baseScopeClassName}OnWeaver';
  buffer.writeln(
    '''
        extension ${scopeExtensionClassName}AddedToWeaver on Weaver {
          $scopeExtensionClassName get ${baseScopeClassName.camelCase} => $scopeExtensionClassName(ScopeHandlerWeaverProxy(this));
        }

        class $scopeExtensionClassName {
          final ScopeHandlerWeaverProxy weaverInstance;

          final _scopeHandlerDelegate = ${classElement.displayName}();

          $scopeExtensionClassName(this.weaverInstance);

          bool get isIn => weaverInstance.scopes.where((scope) => scope.name == "$scopeName").isNotEmpty;

          ${namedDependenciesQuickAccessMethodsPart.toString()}
        }
      ''',
  );

  buffer.writeln('\n'); // add space
}
