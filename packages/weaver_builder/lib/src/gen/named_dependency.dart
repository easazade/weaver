import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/type_checkers.dart';

void writeNamedDependencies({required StringBuffer buffer, required LibraryElement2 library}) {
  for (final function in library.topLevelFunctions) {
    if (!namedDependencyTypeChecker.hasAnnotationOfExact(function)) continue;

    checkForDuplicateNamedDependencyNames(library.topLevelFunctions);
    validateSourceSyntaxOnNamedDependencyFunction(function);

    final annotation = namedDependencyTypeChecker.firstAnnotationOfExact(function);
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
}
