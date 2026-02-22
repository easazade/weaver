import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:weaver_builder/src/builders/validate_annotations.dart';
import 'package:weaver_builder/src/type_checkers.dart';
import 'package:weaver_builder/src/utils/extensions.dart';

void writeClassesForSwitchScopes({
  required StringBuffer buffer,
  required LibraryElement library,
}) {
  for (final classElement in library.classes) {
    if (!weaverSwitchScopeTypeChecker.hasAnnotationOfExact(classElement)) continue;
    checkForDuplicateScopeNames(library.classes);
    validateSourceSyntaxOnWeaverSwitchScopeClass(classElement);

    final weaverScopeAnnotation = weaverSwitchScopeTypeChecker.firstAnnotationOfExact(classElement)!;

    final methods = classElement.methods;
    final onEnterScopeMethods = methods.where((method) => onEnterScopeTypeChecker.hasAnnotationOfExact(method));
    final onLeaveScopeMethods = methods.where((method) => onLeaveScopeTypeChecker.hasAnnotationOfExact(method));

    final reader = ConstantReader(weaverScopeAnnotation);
    final baseScopeName = reader.read('name').stringValue;
    final baseScopeClassName = '${baseScopeName.pascalCase.replaceAll('Scope', '')}Scope';
    final baseScopeArgsClassName = 'Base${baseScopeClassName}Args';

    // create arg class
    buffer.writeln(
      '''
      class $baseScopeArgsClassName {}
    ''',
    );

    // create scope classes
    List<ChildScopeInfo> childScopeInfos = [];
    for (var onEnterScopeMethod in onEnterScopeMethods) {
      final onEnterScopeAnnotation = onEnterScopeTypeChecker.firstAnnotationOfExact(onEnterScopeMethod);
      final reader = ConstantReader(onEnterScopeAnnotation);
      final childScopeName = reader.read('name').stringValue;
      final scopeName = '$baseScopeName${childScopeName.pascalCase}'.paramCase;
      final childScopeClassName =
          '${baseScopeName.pascalCase.replaceAll('Scope', '')}${childScopeName.pascalCase}Scope';
      final params = onEnterScopeMethod.formalParameters;
      final scopeArgsClassName =
          params.length > 1 ? '$baseScopeClassName${childScopeName.pascalCase}Args' : baseScopeArgsClassName;
      var scopeClassArgs = <FormalParameterElement>[];

      final onLeaveMethod = onLeaveScopeMethods.firstWhereOrNull((method) {
        final annotation = onLeaveScopeTypeChecker.firstAnnotationOf(method);
        final reader = ConstantReader(annotation);
        return reader.read('name').stringValue == childScopeName;
      });
      final onLeaveMethodName = onLeaveMethod?.displayName;

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
          : "$baseScopeArgsClassName()";

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

      final argsMap = <String, String?>{}
        ..addEntries(scopeClassArgs.map((e) => MapEntry(e.displayName, e.type.displayNameWithNullability)));

      childScopeInfos.add(
        ChildScopeInfo(
          name: childScopeName,
          fullName: scopeName,
          className: childScopeClassName,
          argClassName: scopeArgsClassName,
          args: argsMap,
          delegateOnEnterMethodName: onEnterScopeMethod.displayName,
          delegateOnLeaveMethodName: onLeaveMethodName,
        ),
      );
    }

    // add a unified scope class that has a builder method for all child-scopes and properties for their scope-names

    buffer.writeln(
      '''
        class $baseScopeClassName {
        $baseScopeClassName._();
    ''',
    );
    for (final info in childScopeInfos) {
      var arguments = info.args.entries
          .map((entry) {
            final type = entry.value;
            final isNullable = type?.endsWith('?') ?? false;
            final argName = entry.key;
            return '${isNullable ? "" : "required"} $type $argName';
          })
          .join(',')
          .trim();
      if (arguments.isNotEmpty) {
        arguments = '{$arguments}';
      }
      buffer.writeln('static ${info.className} ${info.name.camelCase}($arguments)'
          ' => ${info.className}(${info.args.keys.map((key) => '$key: $key').join(',')});\n');
    }

    for (final info in childScopeInfos) {
      buffer.writeln('static String get ${info.name.camelCase}ScopeName => "${info.fullName}";');
    }

    buffer.writeln('}');

    // create scope-handler class
    final scopeHandlerClassName =
        '${baseScopeName.pascalCase.replaceAll('Scope', '').replaceAll('Handler', '')}ScopeHandler';

    buffer.writeln(
      '''
        class $scopeHandlerClassName extends SwitchScopeHandler<$baseScopeArgsClassName> {
        $scopeHandlerClassName(super.weaver, {super.defaultScope});

        final _scopeHandlerDelegate = ${classElement.displayName}();
        final _allScopeNames = [${childScopeInfos.map((e) => "'${e.fullName}'").join(',')}];

        @override
        String get scopeName => '$baseScopeName';

        @override
        bool canHandleScope(String scopeName) => _allScopeNames.contains(scopeName);

    ''',
    );

    // onEnterScopeByScope - start
    buffer.writeln(
      '''
        @override
        Future<void> onEnterScopeByScope(Scope<dynamic> scope) async {
    ''',
    );

    for (var info in childScopeInfos) {
      if (info.argClassName == baseScopeArgsClassName) {
        buffer.writeln(
          '''
          if(scope.name == '${info.fullName}'){
            await _scopeHandlerDelegate.${info.delegateOnEnterMethodName}(weaverInstance);
          }
        ''',
        );
      } else {
        buffer.writeln(
          '''
        if(scope.name == '${info.fullName}'){
          final args = scope.args as ${info.argClassName};
          await _scopeHandlerDelegate.${info.delegateOnEnterMethodName}(weaverInstance, ${info.args.keys.map((argName) => 'args.$argName').join(',')});
        }
      ''',
        );
      }
    }

    // onEnterScopeByScope - end
    buffer.writeln('}');

    // overriding onLeaveScopeByName method
    if (onLeaveScopeMethods.isNotEmpty) {
      buffer.writeln(
        '''
          @override
          Future<void> onLeaveScopeByName(String scopeName) async {
      ''',
      );

      for (final info in childScopeInfos) {
        if (info.delegateOnLeaveMethodName != null) {
          buffer.writeln(
            '''
            if(scopeName == '${info.fullName}'){
              await _scopeHandlerDelegate.${info.delegateOnLeaveMethodName}(weaverInstance);
            } else
          ''',
          );
        }
      }

      buffer.writeln(
        '''
        {
          weaverInstance.unregisterDependenciesRegisteredByThisProxy();
        }
      }
      ''',
      );
    } else {
      buffer.writeln('''
          @override
          Future<void> onLeaveScopeByName(String name) async {
            // no methods are annotated with @OnLeaveScope in the scope handler delegate for
            // custom disposal and unregistering of the dependencies registered for this scope
            weaverInstance.unregisterDependenciesRegisteredByThisProxy();
          }
        ''');
    }

    buffer.writeln('}'); // end of scope handler class

    // Create extension class on Weaver

    final scopeExtensionClassName = '${baseScopeClassName}OnWeaver';

    // create child scope check methods
    final childScopeChecksPart = StringBuffer();
    for (final info in childScopeInfos) {
      childScopeChecksPart.writeln(
        'bool get is${info.name.pascalCase} => weaverInstance.isInScope("${info.fullName}");',
      );
    }

    buffer.writeln(
      '''
        extension ${scopeExtensionClassName}AddedToWeaver on Weaver {
          $scopeExtensionClassName get ${baseScopeClassName.camelCase} => $scopeExtensionClassName(ScopeHandlerWeaverProxy(this));
        }

        class $scopeExtensionClassName {
          final ScopeHandlerWeaverProxy weaverInstance;

          final _scopeHandlerDelegate = ${classElement.displayName}();

          $scopeExtensionClassName(this.weaverInstance);

          $childScopeChecksPart

          Scope<$baseScopeArgsClassName>? get currentScope {
            final matches = weaverInstance.scopes.whereType<Scope<$baseScopeArgsClassName>>();
            return matches.firstOrNull;
          }

          @Deprecated('Use ensureEnterScope() method instead')
          Future<Scope<$baseScopeArgsClassName>> awaitEnterScope() => ensureEnterScope();

          /// This method can be used to wait and ensure for enter scope.
          /// If scope has already entered Returns current scope.
          Future<Scope<$baseScopeArgsClassName>> ensureEnterScope() async {
            final matches = weaverInstance.handlers.whereType<$scopeHandlerClassName>();
            if (matches.isEmpty) {
              throw WeaverException(
                'Tried to await entering a scope without a handler class registered. '
                'Please register an instance of $scopeHandlerClassName first before calling awaitEnterScope()',
              );
            }

            final handler = matches.first;
            return handler.ensureEnterScope();
          }

          Stream<Scope<$baseScopeArgsClassName>?> get stream {
            final matches = weaverInstance.handlers.whereType<$scopeHandlerClassName>();
            if (matches.isEmpty) {
              throw WeaverException(
                'Tried to listen on stream of $baseScopeName switch-scope without a handler class registered. '
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

class ChildScopeInfo {
  final String name;
  final String fullName;
  final String argClassName;
  final String className;
  final String delegateOnEnterMethodName;
  final String? delegateOnLeaveMethodName;
  final Map<String, String?> args;

  ChildScopeInfo({
    required this.name,
    required this.fullName,
    required this.argClassName,
    required this.className,
    required this.args,
    required this.delegateOnEnterMethodName,
    required this.delegateOnLeaveMethodName,
  });
}
