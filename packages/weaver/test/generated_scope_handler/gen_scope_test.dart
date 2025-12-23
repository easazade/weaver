import 'package:test/test.dart';
import 'package:weaver/weaver.dart';

part 'gen_scope_test.weaver.dart';

const key1 = 'key1';
const value1 = 'value1';
const namedKey1 = 'named-key-1';
const namedValue1 = 'named-value-1';
const namedKey2 = 'named-key-2';
const namedValue2 = 'named-value-2';

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

void main() {
  setUp(() async {
    weaver.allowReassignment = true;
    await weaver.addScopeHandler(GeneratedTestScopeHandler());
  });

  tearDown(() async {
    weaver.reset();
  });

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

  test('Should create auto register/unregister named values when entered/left scope', () async {
    expect(weaver.isRegistered(name: namedKey1), isFalse);
    expect(weaver.isRegistered(name: namedKey2), isFalse);

    await weaver.enterScope(GeneratedTestScope(arg: 1));

    expect(weaver.isRegistered(name: namedKey1), isTrue);
    expect(weaver.isRegistered(name: namedKey2), isTrue);

    expect(weaver.get<String>(name: namedKey1), namedValue1);
    expect(weaver.get<String>(name: namedKey2), namedValue2);

    expect(weaver.generatedTest.namedKey1, namedValue1);
    expect(weaver.generatedTest.namedKey2, namedValue2);

    await weaver.leaveScope(GeneratedTestScope.scopeName);

    expect(weaver.isRegistered(name: namedKey1), isFalse);
    // should not be unregistered after leaving scope since this named value has set autoDispose to false
    expect(weaver.isRegistered(name: namedKey2), isTrue);
  });
}
