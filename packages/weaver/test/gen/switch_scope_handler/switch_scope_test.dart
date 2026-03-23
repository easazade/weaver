import 'dart:async';

import 'package:test/test.dart';
import 'package:weaver/weaver.dart';

import 'switch_scopes.dart';

void main() {
  setUp(() async {
    // Cast SwitchScopeHandler to SingleScopeHandler for addScopeHandler method
    // Both extend ScopeHandler and the internal list accepts ScopeHandler
    await weaver.addScopeHandler(AccessScopeHandler(weaver));
  });

  tearDown(() async {
    weaver.reset();
  });

  group('Entering child scopes', () {
    test('Should register objects when entering Access Admin scope', () async {
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isFalse);

      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key-123', id: 42));
      expect(weaver.isInScope(AccessScope.adminScopeName), isTrue);
      expect(weaver.isRegistered<String>(), isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);

      final adminAPI = weaver.get<AdminAPI>();
      expect(adminAPI.adminKey, 'admin-key-123');
      expect(adminAPI.id, 42);
    });

    test('Should register objects when entering Access User scope', () async {
      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 100));

      expect(weaver.isInScope(AccessScope.userScopeName), isTrue);
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      final userAPI = weaver.get<UserAPI>();
      expect(userAPI.userId, 100);
    });

    test('Should register objects when entering Access Public scope', () async {
      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);

      await weaver.enterScope(AccessScope.public(flag: true));

      expect(weaver.isInScope(AccessScope.publicScopeName), isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      final publicAPI = weaver.get<PublicAPI>();
      expect(publicAPI.flag, isTrue);
    });

    test('Should register objects when entering Access Dev scope', () async {
      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);
      expect(weaver.isRegistered<DevAPI>(), isFalse);

      await weaver.enterScope(AccessScope.dev());

      expect(weaver.isInScope(AccessScope.devScopeName), isTrue);
      expect(weaver.isRegistered<DevAPI>(), isTrue);
    });

    test('Should handle optional id parameter in Admin scope', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'key-without-id'));

      expect(weaver.isRegistered<AdminAPI>(), isTrue);
      final adminAPI = weaver.get<AdminAPI>();
      expect(adminAPI.adminKey, 'key-without-id');
      expect(adminAPI.id, isNull);
    });
  });

  group('Leaving child scopes', () {
    test('Should unregister objects when leaving Access Admin scope', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key', id: 1));
      expect(weaver.isRegistered<String>(), isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);

      await weaver.leaveScope(AccessScope.adminScopeName);

      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      // AdminAPI should be unregistered via @OnLeaveScope
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      // String should also be unregistered (default behavior)
      expect(weaver.isRegistered<String>(), isFalse);
    });

    test('Should unregister objects when leaving Access User scope', () async {
      await weaver.enterScope(AccessScope.user(userId: 200));
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      await weaver.leaveScope(AccessScope.userScopeName);

      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);
    });

    test('Should unregister objects when leaving Access Public scope', () async {
      await weaver.enterScope(AccessScope.public(flag: false));
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      await weaver.leaveScope(AccessScope.publicScopeName);

      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);
    });

    test('Should unregister objects when leaving Access Dev scope', () async {
      await weaver.enterScope(AccessScope.dev());
      expect(weaver.isRegistered<DevAPI>(), isTrue);

      await weaver.leaveScope(AccessScope.devScopeName);

      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);
      expect(weaver.isRegistered<DevAPI>(), isFalse);
    });
  });

  group('Switching between child scopes', () {
    test('Should unregister Admin scope objects when switching to User scope', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key', id: 1));
      expect(weaver.isRegistered<String>(), isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);
      expect(weaver.isRegistered<UserAPI>(), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 300));

      // Admin scope should be left
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);

      // User scope should be active
      expect(weaver.isInScope(AccessScope.userScopeName), isTrue);
      expect(weaver.isRegistered<UserAPI>(), isTrue);
      expect(weaver.get<UserAPI>().userId, 300);
    });

    test('Should unregister User scope objects when switching to Public scope', () async {
      await weaver.enterScope(AccessScope.user(userId: 400));
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      await weaver.enterScope(AccessScope.public(flag: true));

      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);

      expect(weaver.isInScope(AccessScope.publicScopeName), isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);
    });

    test('Should unregister Public scope objects when switching to Dev scope', () async {
      await weaver.enterScope(AccessScope.public(flag: false));
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      await weaver.enterScope(AccessScope.dev());

      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);

      expect(weaver.isInScope(AccessScope.devScopeName), isTrue);
      expect(weaver.isRegistered<DevAPI>(), isTrue);
    });

    test('Should unregister Dev scope objects when switching to Admin scope', () async {
      await weaver.enterScope(AccessScope.dev());
      expect(weaver.isRegistered<DevAPI>(), isTrue);

      await weaver.enterScope(AccessScope.admin(adminKey: 'new-admin', id: 99));

      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);
      expect(weaver.isRegistered<DevAPI>(), isFalse);

      expect(weaver.isInScope(AccessScope.adminScopeName), isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);
      expect(weaver.get<AdminAPI>().adminKey, 'new-admin');
    });

    test('Should handle multiple switches between different scopes', () async {
      // Start with Admin
      await weaver.enterScope(AccessScope.admin(adminKey: 'admin1', id: 1));
      expect(weaver.isRegistered<AdminAPI>(), isTrue);

      // Switch to User
      await weaver.enterScope(AccessScope.user(userId: 100));
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      // Switch to Public
      await weaver.enterScope(AccessScope.public(flag: true));
      expect(weaver.isRegistered<UserAPI>(), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      // Switch back to Admin
      await weaver.enterScope(AccessScope.admin(adminKey: 'admin2', id: 2));
      expect(weaver.isRegistered<PublicAPI>(), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);
      expect(weaver.get<AdminAPI>().adminKey, 'admin2');
    });
  });

  group('Scope state tracking', () {
    test('Should correctly track which child scope is active', () async {
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);

      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.isInScope(AccessScope.adminScopeName), isTrue);
      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 50));
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.userScopeName), isTrue);
    });

    test('Should only have one child scope active at a time', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.isInScope(AccessScope.adminScopeName), isTrue);
      expect(weaver.isInScope(AccessScope.userScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 10));
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.userScopeName), isTrue);
      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isInScope(AccessScope.devScopeName), isFalse);
    });
  });

  group('Extension methods', () {
    test('Should provide extension methods to check scope state', () async {
      expect(weaver.accessScope.isAdmin, isFalse);
      expect(weaver.accessScope.isUser, isFalse);
      expect(weaver.accessScope.isPublic, isFalse);
      expect(weaver.accessScope.isDev, isFalse);

      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.accessScope.isAdmin, isTrue);
      expect(weaver.accessScope.isUser, isFalse);
      expect(weaver.accessScope.isPublic, isFalse);
      expect(weaver.accessScope.isDev, isFalse);

      await weaver.enterScope(AccessScope.user(userId: 5));
      expect(weaver.accessScope.isAdmin, isFalse);
      expect(weaver.accessScope.isUser, isTrue);
      expect(weaver.accessScope.isPublic, isFalse);
      expect(weaver.accessScope.isDev, isFalse);
    });

    test('Should provide current scope correctly', () async {
      expect(weaver.accessScope.currentScope, isNull);

      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.accessScope.currentScope, isA<AccessAdminScope>());

      await weaver.enterScope(AccessScope.user(userId: 5));
      expect(weaver.accessScope.currentScope, isA<AccessUserScope>());
    });
  });

  group('stream', () {
    test('Should emit scope when entering scope and null when leaving scope', () async {
      final handler = weaver.handlers.whereType<AccessScopeHandler>().first;

      final emittedValues = <Scope<BaseAccessScopeArgs>?>[];
      final completer = Completer<void>();
      handler.stream.listen((final value) {
        emittedValues.add(value);
        if (emittedValues.length == 2) {
          completer.complete();
        }
      });

      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key', id: 42));
      await weaver.leaveScope(AccessScope.adminScopeName);
      await completer.future;

      expect(emittedValues.length, 2);
      expect(emittedValues[0], isA<AccessAdminScope>());
      expect((emittedValues[0] as AccessAdminScope).args.adminKey, 'admin-key');
      expect(emittedValues[1], isNull);
    });

    test('Should emit scopes when switching between child scopes', () async {
      final handler = weaver.handlers.whereType<AccessScopeHandler>().first;

      final emittedValues = <Scope<BaseAccessScopeArgs>?>[];
      final completer = Completer<void>();
      handler.stream.listen((final value) {
        emittedValues.add(value);
        if (emittedValues.length == 3) {
          completer.complete();
        }
      });

      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key', id: 1));
      await weaver.enterScope(AccessScope.user(userId: 100));
      await weaver.enterScope(AccessScope.public(flag: true));
      await completer.future;

      expect(emittedValues.length, 3);
      expect(emittedValues[0], isA<AccessAdminScope>());
      expect(emittedValues[1], isA<AccessUserScope>());
      expect((emittedValues[1] as AccessUserScope).args.userId, 100);
      expect(emittedValues[2], isA<AccessPublicScope>());
    });

    test('Should emit default scope when handler is added with defaultScope', () async {
      weaver.reset();

      final handler = AccessScopeHandler(weaver, defaultScope: AccessScope.public(flag: true));
      final emittedValues = <Scope<BaseAccessScopeArgs>?>[];
      final completer = Completer<void>();
      handler.stream.listen((final value) {
        emittedValues.add(value);
        if (emittedValues.length == 1) {
          completer.complete();
        }
      });

      await weaver.addScopeHandler(handler);
      await completer.future;

      expect(emittedValues.length, 1);
      expect(emittedValues[0], isA<AccessPublicScope>());
      expect((emittedValues[0] as AccessPublicScope).args.flag, isTrue);
    });
  });

  group('changeScopeStream', () {
    late StreamController<Scope<BaseAccessScopeArgs>?> scopeSignal;

    setUp(() async {
      weaver.allowReassignment = true;
      weaver.reset();
      scopeSignal = StreamController<Scope<BaseAccessScopeArgs>?>();
      await weaver.addScopeHandler(
        AccessScopeHandler(weaver, changeScopeStream: scopeSignal.stream),
      );
    });

    tearDown(() async {
      await scopeSignal.close();
      weaver.reset();
    });

    Future<void> pumpScopeStream() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    test('Should enter admin scope when stream emits admin scope', () async {
      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);

      scopeSignal.add(AccessScope.admin(adminKey: 'stream-key', id: 11));
      await pumpScopeStream();

      expect(weaver.isInScope(AccessScope.adminScopeName), isTrue);
      expect(weaver.get<AdminAPI>().adminKey, 'stream-key');
      expect(weaver.get<AdminAPI>().id, 11);
    });

    test('Should switch from admin to user when stream emits a different child scope', () async {
      scopeSignal.add(AccessScope.admin(adminKey: 'a', id: 1));
      await pumpScopeStream();
      expect(weaver.isRegistered<AdminAPI>(), isTrue);

      scopeSignal.add(AccessScope.user(userId: 55));
      await pumpScopeStream();

      expect(weaver.isInScope(AccessScope.adminScopeName), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      expect(weaver.isInScope(AccessScope.userScopeName), isTrue);
      expect(weaver.get<UserAPI>().userId, 55);
    });

    test('Should leave active child when stream emits null and no defaultScope', () async {
      scopeSignal.add(AccessScope.public(flag: false));
      await pumpScopeStream();
      expect(weaver.isInScope(AccessScope.publicScopeName), isTrue);

      scopeSignal.add(null);
      await pumpScopeStream();

      expect(weaver.isInScope(AccessScope.publicScopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);
      expect(weaver.accessScope.currentScope, isNull);
    });

    test('Should return to defaultScope when stream emits null after leaving a child', () async {
      await scopeSignal.close();
      weaver.reset();
      scopeSignal = StreamController<Scope<BaseAccessScopeArgs>?>();
      await weaver.addScopeHandler(
        AccessScopeHandler(
          weaver,
          changeScopeStream: scopeSignal.stream,
          defaultScope: AccessScope.public(flag: true),
        ),
      );

      scopeSignal.add(AccessScope.admin(adminKey: 'x', id: 1));
      await pumpScopeStream();
      expect(weaver.accessScope.isAdmin, isTrue);

      scopeSignal.add(null);
      await pumpScopeStream();

      expect(weaver.accessScope.isPublic, isTrue);
      expect(weaver.get<PublicAPI>().flag, isTrue);
    });

    test('Should emit on handler stream when switching via changeScopeStream', () async {
      final handler = weaver.handlers.whereType<AccessScopeHandler>().first;
      final emissions = <Scope<BaseAccessScopeArgs>?>[];
      final done = Completer<void>();
      handler.stream.listen((final value) {
        emissions.add(value);
        if (emissions.length == 3) {
          done.complete();
        }
      });

      scopeSignal.add(AccessScope.dev());
      await pumpScopeStream();
      scopeSignal.add(AccessScope.user(userId: 9));
      await pumpScopeStream();
      scopeSignal.add(AccessScope.public(flag: true));
      await pumpScopeStream();
      await done.future;

      expect(emissions[0], isA<AccessDevScope>());
      expect(emissions[1], isA<AccessUserScope>());
      expect((emissions[1] as AccessUserScope).args.userId, 9);
      expect(emissions[2], isA<AccessPublicScope>());
    });
  });

  group('ensureEnterScope', () {
    test('Should return current scope immediately when scope is already entered', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key', id: 42));

      final scope = await weaver.accessScope.ensureEnterScope();
      expect(scope, isA<AccessAdminScope>());
      expect((scope as AccessAdminScope).args.adminKey, 'admin-key');
      expect(scope.args.id, 42);
    });

    test('Should wait for scope to be entered when no scope is active', () async {
      // Leave any existing scope first
      if (weaver.accessScope.currentScope != null) {
        await weaver.leaveScope(weaver.accessScope.currentScope!.name);
      }

      // Verify no scope is active
      expect(weaver.accessScope.currentScope, isNull);

      // Start awaiting before entering scope
      Scope<BaseAccessScopeArgs>? enteredScope;
      unawaited(weaver.accessScope.ensureEnterScope().then((final scope) {
        enteredScope = scope;
      }));

      // Enter scope asynchronously after a short delay
      Future.delayed(const Duration(milliseconds: 50), () async {
        await weaver.enterScope(AccessScope.user(userId: 100));
      });
      await Future.delayed(const Duration(milliseconds: 100));

      // Wait for the future to complete
      expect(enteredScope, isA<AccessUserScope>());
      expect((enteredScope as AccessUserScope).args.userId, 100);
    });

    test('Should return new scope after switching scopes', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'old-admin', id: 1));
      expect(await weaver.accessScope.ensureEnterScope(), isA<AccessAdminScope>());

      // Switch to user scope
      await weaver.enterScope(AccessScope.user(userId: 200));

      // ensureEnterScope should return the new scope immediately
      final scope = await weaver.accessScope.ensureEnterScope();
      expect(scope, isA<AccessUserScope>());
      expect((scope as AccessUserScope).args.userId, 200);
    });

    test('Should throw exception when handler is not registered', () async {
      weaver.reset();

      expect(
        () => weaver.accessScope.ensureEnterScope(),
        throwsA(isA<WeaverException>()),
      );
    });

    test('Should return correct scope type for different scope types', () async {
      // Test Admin scope
      await weaver.enterScope(AccessScope.admin(adminKey: 'key1', id: 1));
      var scope = await weaver.accessScope.ensureEnterScope();
      expect(scope, isA<AccessAdminScope>());

      // Test Public scope
      await weaver.enterScope(AccessScope.public(flag: true));
      scope = await weaver.accessScope.ensureEnterScope();
      expect(scope, isA<AccessPublicScope>());
      expect((scope as AccessPublicScope).args.flag, isTrue);

      // Test Dev scope
      await weaver.enterScope(AccessScope.dev());
      scope = await weaver.accessScope.ensureEnterScope();
      expect(scope, isA<AccessDevScope>());
    });
  });

  group('Default scope', () {
    test('Default scope should be entered as soon as the SwitchScopeHandler is added to weaver', () async {
      weaver.reset();
      expect(weaver.isRegistered<PublicAPI>(), isFalse);

      await weaver.addScopeHandler(AccessScopeHandler(weaver, defaultScope: AccessScope.public(flag: true)));
      expect(weaver.isRegistered<PublicAPI>(), isTrue);
    });

    test('SwitchScopeHandler should switch back to default scope after left current scope.', () async {
      weaver.reset();

      final handler = AccessScopeHandler(weaver, defaultScope: AccessScope.public(flag: true));
      await weaver.addScopeHandler(handler);
      expect(weaver.accessScope.isPublic, isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      await weaver.enterScope(AccessScope.admin(adminKey: 'adminKey'));
      expect(weaver.accessScope.isAdmin, isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);
      expect(weaver.accessScope.isPublic, isFalse);

      await weaver.leaveScope(AccessScope.adminScopeName);
      expect(weaver.accessScope.isPublic, isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);
    });
  });
}
