import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver/annotations.dart';
import 'package:weaver_builder/src/utils/extensions.dart';

final _onEnterScopeTypeChecker = const TypeChecker.fromRuntime(OnEnterScope);
final _onLeaveScopeTypeChecker = const TypeChecker.fromRuntime(OnLeaveScope);

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

  if (onEnterScopeMethod == null || onLeaveScopeMethod == null) {
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
        'Correct ✅: ${onEnterScopeMethod.displayName}(Weaver weaver, WeaverState state, String arg1, int, arg2, ...) \n'
        'Incorrect ❌: ${onEnterScopeMethod.displayName}({Weaver weaver, WeaverState state, String arg1, int, arg2, ...})',
      );
    }
  }

  // validating the syntax of @onLeaveScope method

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

void validateSourceSyntaxOnNamedDependencyFunction(TopLevelFunctionElement function) {
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
