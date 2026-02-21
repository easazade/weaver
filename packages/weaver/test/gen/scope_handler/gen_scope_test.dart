import 'dart:async';

import 'package:test/test.dart';
import 'package:weaver/weaver.dart';

part 'gen_scope_test.weaver.dart';

const key1 = 'key1';
const value1 = 'value1';
const namedKey1 = 'named-key-1';
const namedValue1 = 'named-value-1';
const namedKey2 = 'named-key-2';
const namedValue2 = 'named-value-2';
const namedKey3 = 'named-key-3';
const namedValue3 = 'named-value-3';

@WeaverScope(name: 'generated-test')
class _GeneratedTestScope {
  @OnEnterScope()
  Future<void> onEnterScope(final Weaver weaver, final double? optionalArg, final int arg) async {
    weaver.register<String>(value1);
    weaver.register<int>(arg);
    if (optionalArg != null) {
      weaver.register<double>(optionalArg);
    }
  }

  @NamedDependency(name: namedKey1)
  String _namedValue1() => namedValue1;

  @NamedDependency(name: namedKey2, autoDispose: false)
  String _namedValue2() => namedValue2;

  @OnLeaveScope()
  Future<void> onLeave(final Weaver weaverInstance) async {
    weaver.unregister<String>();
    weaver.unregister<int>();
    weaver.unregister<double>();
  }
}

@WeaverScope(name: 'generated-test-2')
class _GeneratedTestScope2 {
  @OnEnterScope()
  Future<void> onEnterScope(final Weaver weaver) async {
    weaver.register<bool>(true);
  }

  @NamedDependency(name: namedKey3)
  String _namedValue3() => namedValue3;
}

void main() {
  late GeneratedTestScopeHandler testScopeHandler;
  late GeneratedTest2ScopeHandler test2ScopeHandler;

  setUp(() async {
    weaver.allowReassignment = true;
    testScopeHandler = GeneratedTestScopeHandler(weaver);
    test2ScopeHandler = GeneratedTest2ScopeHandler(weaver);
    await weaver.addScopeHandler(testScopeHandler);
    await weaver.addScopeHandler(test2ScopeHandler);
  });

  tearDown(() async {
    weaver.reset();
  });

  group('Scope lifecycle', () {
    test('Should register values added in @OnEnterScope and unregister values removed in @OnLeaveScope ', () async {
      expect(weaver.isInScope(GeneratedTestScope.scopeName), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);
      expect(weaver.isRegistered<int>(), isFalse);

      await weaver.enterScope(GeneratedTestScope(arg: 1));

      expect(weaver.isInScope(GeneratedTestScope.scopeName), isTrue);
      expect(weaver.isRegistered<String>(), isTrue);
      expect(weaver.isRegistered<int>(), isTrue);

      await weaver.leaveScope(GeneratedTestScope.scopeName);

      expect(weaver.isInScope(GeneratedTestScope.scopeName), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);
      expect(weaver.isRegistered<int>(), isFalse);
    });

    test('Should register optional value if passed as arg when entering scope', () async {
      expect(weaver.isRegistered<double>(), isFalse);

      await weaver.enterScope(GeneratedTestScope(arg: 1, optionalArg: 2));

      expect(weaver.isRegistered<double>(), isTrue);
      expect(weaver.get<double>(), equals(2));
    });
  });

  group('Named dependencies', () {
    test('Should create auto register/unregister named values when entered/left scope', () async {
      expect(weaver.isRegistered(name: namedKey1), isFalse);
      expect(weaver.isRegistered(name: namedKey2), isFalse);

      await weaver.enterScope(GeneratedTestScope(arg: 1));

      expect(weaver.isRegistered(name: namedKey1), isTrue);
      expect(weaver.isRegistered(name: namedKey2), isTrue);

      expect(weaver.get<String>(name: namedKey1), namedValue1);
      expect(weaver.get<String>(name: namedKey2), namedValue2);

      expect(weaver.generatedTestScope.namedKey1, namedValue1);
      expect(weaver.generatedTestScope.namedKey2, namedValue2);

      await weaver.leaveScope(GeneratedTestScope.scopeName);

      expect(weaver.isRegistered(name: namedKey1), isFalse);
      // should not be unregistered after leaving scope since this named value has set autoDispose to false
      expect(weaver.isRegistered(name: namedKey2), isTrue);
    });
  });

  group('Leaving scope', () {
    test(
      'Should create auto unregister values registered when no custom method is annotated with @OnLeaveScope'
      'inside the scope class defined ',
      () async {
        expect(weaver.isRegistered(name: namedKey3), isFalse);
        expect(weaver.isRegistered<bool>(), isFalse);

        await weaver.enterScope(GeneratedTest2Scope());

        expect(weaver.isRegistered<bool>(), isTrue);
        expect(weaver.isRegistered(name: namedKey3), isTrue);
        expect(weaver.generatedTest2Scope.namedKey3, namedValue3);

        await weaver.leaveScope(GeneratedTest2Scope.scopeName);

        expect(weaver.isRegistered<bool>(), false);
        expect(weaver.isRegistered(name: namedKey3), isFalse);
      },
    );
  });

  group('stream', () {
    test('Should emit scope when entering scope and null when leaving scope', () async {
      final emittedValues = <Scope<GeneratedTestScopeArgs>?>[];
      final completer = Completer<void>();
      testScopeHandler.stream.listen((final value) {
        emittedValues.add(value);
        if (emittedValues.length == 2) {
          completer.complete();
        }
      });

      await weaver.enterScope(GeneratedTestScope(arg: 42));
      await weaver.leaveScope(GeneratedTestScope.scopeName);
      await completer.future;

      expect(emittedValues.length, 2);
      expect(emittedValues[0], isA<GeneratedTestScope>());
      expect((emittedValues[0] as GeneratedTestScope).args.arg, 42);
      expect(emittedValues[1], isNull);
    });

    test('Should emit scopes for multiple enter/leave cycles', () async {
      final emittedValues = <Scope<GeneratedTestScopeArgs>?>[];
      final completer = Completer<void>();
      testScopeHandler.stream.listen((final value) {
        emittedValues.add(value);
        if (emittedValues.length == 3) {
          completer.complete();
        }
      });

      await weaver.enterScope(GeneratedTestScope(arg: 1));
      await weaver.leaveScope(GeneratedTestScope.scopeName);
      await weaver.enterScope(GeneratedTestScope(arg: 2));
      await completer.future;

      expect(emittedValues.length, 3);
      expect((emittedValues[0] as GeneratedTestScope).args.arg, 1);
      expect(emittedValues[1], isNull);
      expect((emittedValues[2] as GeneratedTestScope).args.arg, 2);
    });
  });

  group('ensureEnterScope', () {
    test('Should return current scope immediately when scope is already entered', () async {
      await weaver.enterScope(GeneratedTestScope(arg: 42));

      final handler = weaver.handlers.firstWhere(
        (final h) => h.canHandleScope(GeneratedTestScope.scopeName),
      );
      final scope = await handler.ensureEnterScope();

      expect(scope, isA<GeneratedTestScope>());
      expect((scope as GeneratedTestScope).args.arg, 42);
    });

    test('Should wait for scope to be entered when no scope is active', () async {
      expect(weaver.isInScope(GeneratedTestScope.scopeName), isFalse);

      final handler = weaver.handlers.firstWhere(
        (final h) => h.canHandleScope(GeneratedTestScope.scopeName),
      );

      Scope? enteredScope;
      unawaited(handler.ensureEnterScope().then((final scope) {
        enteredScope = scope;
      }));

      Future.delayed(const Duration(milliseconds: 50), () async {
        await weaver.enterScope(GeneratedTestScope(arg: 100));
      });
      await Future.delayed(const Duration(milliseconds: 100));

      expect(enteredScope, isA<GeneratedTestScope>());
      expect((enteredScope as GeneratedTestScope).args.arg, 100);
    });
  });
}
