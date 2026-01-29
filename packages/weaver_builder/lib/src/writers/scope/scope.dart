import 'package:analyzer/dart/element/element2.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/gen/multi_scope.dart';
import 'package:weaver_builder/src/type_checkers.dart';
import 'package:weaver_builder/src/writers/scope/single_scope.dart';

void writeScopes({required StringBuffer buffer, required LibraryElement2 library}) {
  for (final classElement in library.classes) {
    if (!weaverScopeTypeChecker.hasAnnotationOfExact(classElement)) continue;
    checkForDuplicateScopeNames(library.classes);
    validateSourceSyntaxOnWeaverScopeClass(classElement);

    final methods = classElement.methods2;
    final onEnterScopeMethods = methods.where((method) => onEnterScopeTypeChecker.hasAnnotationOfExact(method));

    if (onEnterScopeMethods.length > 1) {
      writeClassesForMultiScope(buffer: buffer, library: library, classElement: classElement);
    } else {
      writeClassesForSingleScope(buffer: buffer, library: library, classElement: classElement);
    }
  }
}
