import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/utils/extensions.dart';

final _onEnterScopeTypeChecker = const TypeChecker.typeNamed(OnEnterScope);
final _onLeaveScopeTypeChecker = const TypeChecker.typeNamed(OnLeaveScope);

/// Checks if the annotated classes with [WeaverScope] annotation have duplicate names
void checkForDuplicateScopeNames(List<ClassElement2> classes) {
  final weaverScopeTypeChecker = const TypeChecker.typeNamed(WeaverScope);
  final annotatedClasses = classes.where((cls) => weaverScopeTypeChecker.hasAnnotationOfExact(cls));
  if (annotatedClasses.isNotEmpty) {
    final scopeNamesList = annotatedClasses.map((annotatedClass) {
      final reader = ConstantReader(weaverScopeTypeChecker.firstAnnotationOfExact(annotatedClass));
      final scopeName = reader.read('name').stringValue;
      return scopeName;
    });

    // there should be one scope name per annotated class
    if (scopeNamesList.toSet().length != annotatedClasses.length) {
      throw InvalidGenerationSource(
        '❌ classes annotated with @WeaverScope(name: "name") annotation cannot have the same annotation name value. '
        'Here are all the name values defined in all classes annotated with @WeaverScope: $scopeNamesList',
      );
    }
  }
}

/// Checks if the annotated classes with [NamedDependency] annotation have duplicate names
void checkForDuplicateNamedDependencyNames(List<ExecutableElement2> classes) {
  final namedDependencyTypeChecker = const TypeChecker.typeNamed(NamedDependency);
  final annotatedFunctions = classes.where((function) => namedDependencyTypeChecker.hasAnnotationOfExact(function));
  if (annotatedFunctions.isNotEmpty) {
    final dependencyNames = annotatedFunctions.map((annotatedFunction) {
      final reader = ConstantReader(namedDependencyTypeChecker.firstAnnotationOfExact(annotatedFunction));
      final dependencyName = reader.read('name').stringValue;
      return dependencyName;
    });

    // there should be one scope name per annotated class
    if (dependencyNames.toSet().length != annotatedFunctions.length) {
      throw InvalidGenerationSource(
        '❌ functions annotated with @NamedDependency(name: "var-name") annotation cannot have the same annotation name value. '
        'Here are all the name values defined in all functions annotated with @NamedDependency: $dependencyNames',
      );
    }
  }
}

/// Checks if the input source code for WeaverScope annotated class is valid and as expected.
/// Throws a [InvalidGenerationSource] if otherwise.
void validateSourceSyntaxOnWeaverScopeClass(ClassElement2 classElement) {
  final hasCustomConstructor = classElement.constructors2.firstWhereOrNull((e) => !e.isDefaultConstructor) != null;

  if (hasCustomConstructor) {
    throw InvalidGenerationSource(
      '❌ class annotated with @WeaverScope must not have a constructor other that its default constructor',
    );
  }

  if (!classElement.displayName.startsWith('_')) {
    throw InvalidGenerationSource(
      '❌ class annotated with @WeaverScope must be private eg: _${classElement.displayName}',
    );
  }

  final methods = classElement.methods2;
  final onEnterScopeMethod = methods.firstWhereOrNull(
    (method) => _onEnterScopeTypeChecker.hasAnnotationOfExact(method),
  );

  final onLeaveScopeMethod = methods.firstWhereOrNull(
    (method) => _onLeaveScopeTypeChecker.hasAnnotationOfExact(method),
  );

  if (onEnterScopeMethod == null) {
    throw InvalidGenerationSource(
      '''-------------------------------------------------------------------------------------
❌
scope classes annotated with @WeaverScope are required to have methods annotated with 
@OnEnterScope and @OnLeaveScope to handle dependencies when entering and leaving the scope

Example:

@WeaverScope(name: 'my-scope')
class MyScope {

  @OnEnterScope()
  Future<void> onEnterScope(Weaver weaver, String arg1, int arg2) async {
    weaver.register(MyDependency(arg1, arg2));
  }

  // OPTIONAL: @OnLeaveScope is optional and should only be used when it is required 
  // to dispose or do something before unregistering the dependency objects. Otherwise when omitted 
  // weaver will automatically unregister the dependency objects that have been registered in method
  // annotated with onEnterScope.
  @OnLeaveScope()
  Future<void> onLeaveScope(Weaver weaver) async {
    weaver.unregister<MyDependency>();
  }
}
-------------------------------------------------------------------------------------
            ''',
    );
  }

  // validating the syntax of @onEnterScope method

  if (onEnterScopeMethod.formalParameters.isEmpty) {
    throw InvalidGenerationSource(
      '❌ handler function annotated with @OnEnterScope should have its the first parameter of type "Weaver"'
      'eg: ${onEnterScopeMethod.displayName}(Weaver weaver, WeaverState state, ...)',
    );
  }

  final weaverParam = onEnterScopeMethod.formalParameters[0];
  final weaverParamType = weaverParam.type.element3?.displayName;
  if (weaverParamType != 'Weaver') {
    throw InvalidGenerationSource(
      '❌ First parameter of the scope handler function should be of type "Weaver" not "$weaverParamType". '
      'eg: ${onEnterScopeMethod.displayName}(Weaver weaver, WeaverState state, ...)',
    );
  }

  for (final param in onEnterScopeMethod.formalParameters) {
    if (!param.isPositional) {
      throw InvalidGenerationSource(
        'Handler function can only have positional parameters. \n'
        'Correct ✅: ${onEnterScopeMethod.displayName}(Weaver weaver, WeaverState state, String arg1, int arg2, ...) \n'
        'Incorrect ❌: ${onEnterScopeMethod.displayName}({Weaver weaver, WeaverState state, String arg1, int arg2, ...})',
      );
    }
  }

  // validating the syntax of @onLeaveScope method

  if (onLeaveScopeMethod != null) {
    final onLeaveMethodParamType = onLeaveScopeMethod.formalParameters.first.type.element3?.displayName;
    if (onLeaveScopeMethod.formalParameters.length != 1 || onLeaveMethodParamType != 'Weaver') {
      throw InvalidGenerationSource(
        '''❌ method onLeaveScope() should have a single argument of type Weaver. 

Example: 

@OnLeaveScope()
Future<void> onLeaveScope(Weaver weaver) async {
  weaver.unregister<MyDependency>();
}

        ''',
      );
    }
  }
}

void validateSourceSyntaxOnNamedDependencyFunction(ExecutableElement2 function) {
  if (!function.displayName.startsWith('_')) {
    throw InvalidGenerationSource(
      '❌ The factory function for named dependencies should be private but ${function.displayName}() is not.',
    );
  }

  final returnType = function.returnType;
  final objectType = returnType.isDartAsyncFuture
      ? (returnType as ParameterizedType).typeArguments.first.displayNameWithNullability
      : function.returnType.displayNameWithNullability;

  if (returnType.isDartAsyncFuture) {
    throw InvalidGenerationSource(
      '❌ The factory function for named dependencies with return type of Future is not currently '
      'supported but ${function.displayName}() has a return type of Future.',
    );
  }

  if (objectType?.endsWith('?') == true) {
    throw InvalidGenerationSource(
      '❌ The factory function for named dependencies cannot have a nullable return type but ${function.displayName}() does.',
    );
  }
}
