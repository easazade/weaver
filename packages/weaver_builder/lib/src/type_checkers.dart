import 'package:source_gen/source_gen.dart';
import 'package:weaver/annotations.dart';

final weaverScopeTypeChecker = const TypeChecker.typeNamed(WeaverScope);
final weaverSwitchScopeTypeChecker = const TypeChecker.typeNamed(WeaverSwitchScope);
final weaverSessionTypeChecker = const TypeChecker.typeNamed(WeaverSession);
final onEnterScopeTypeChecker = const TypeChecker.typeNamed(OnEnterScope);
final onLeaveScopeTypeChecker = const TypeChecker.typeNamed(OnLeaveScope);
final namedDependencyTypeChecker = const TypeChecker.typeNamed(NamedDependency);
