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
      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isFalse);

      await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key-123', id: 42));
      expect(weaver.isInScope(AccessAdminScope.scopeName), isTrue);
      expect(weaver.isRegistered<String>(), isTrue);
      expect(weaver.isRegistered<AdminAPI>(), isTrue);

      final adminAPI = weaver.get<AdminAPI>();
      expect(adminAPI.adminKey, 'admin-key-123');
      expect(adminAPI.id, 42);
    });

    test('Should register objects when entering Access User scope', () async {
      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 100));

      expect(weaver.isInScope(AccessUserScope.scopeName), isTrue);
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      final userAPI = weaver.get<UserAPI>();
      expect(userAPI.userId, 100);
    });

    test('Should register objects when entering Access Public scope', () async {
      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);

      await weaver.enterScope(AccessScope.public(flag: true));

      expect(weaver.isInScope(AccessPublicScope.scopeName), isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      final publicAPI = weaver.get<PublicAPI>();
      expect(publicAPI.flag, isTrue);
    });

    test('Should register objects when entering Access Dev scope', () async {
      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);
      expect(weaver.isRegistered<DevAPI>(), isFalse);

      await weaver.enterScope(AccessScope.dev());

      expect(weaver.isInScope(AccessDevScope.scopeName), isTrue);
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

      await weaver.leaveScope(AccessAdminScope.scopeName);

      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      // AdminAPI should be unregistered via @OnLeaveScope
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      // String should also be unregistered (default behavior)
      expect(weaver.isRegistered<String>(), isFalse);
    });

    test('Should unregister objects when leaving Access User scope', () async {
      await weaver.enterScope(AccessScope.user(userId: 200));
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      await weaver.leaveScope(AccessUserScope.scopeName);

      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);
    });

    test('Should unregister objects when leaving Access Public scope', () async {
      await weaver.enterScope(AccessScope.public(flag: false));
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      await weaver.leaveScope(AccessPublicScope.scopeName);

      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);
    });

    test('Should unregister objects when leaving Access Dev scope', () async {
      await weaver.enterScope(AccessScope.dev());
      expect(weaver.isRegistered<DevAPI>(), isTrue);

      await weaver.leaveScope(AccessDevScope.scopeName);

      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);
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
      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      expect(weaver.isRegistered<AdminAPI>(), isFalse);
      expect(weaver.isRegistered<String>(), isFalse);

      // User scope should be active
      expect(weaver.isInScope(AccessUserScope.scopeName), isTrue);
      expect(weaver.isRegistered<UserAPI>(), isTrue);
      expect(weaver.get<UserAPI>().userId, 300);
    });

    test('Should unregister User scope objects when switching to Public scope', () async {
      await weaver.enterScope(AccessScope.user(userId: 400));
      expect(weaver.isRegistered<UserAPI>(), isTrue);

      await weaver.enterScope(AccessScope.public(flag: true));

      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);
      expect(weaver.isRegistered<UserAPI>(), isFalse);

      expect(weaver.isInScope(AccessPublicScope.scopeName), isTrue);
      expect(weaver.isRegistered<PublicAPI>(), isTrue);
    });

    test('Should unregister Public scope objects when switching to Dev scope', () async {
      await weaver.enterScope(AccessScope.public(flag: false));
      expect(weaver.isRegistered<PublicAPI>(), isTrue);

      await weaver.enterScope(AccessScope.dev());

      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isRegistered<PublicAPI>(), isFalse);

      expect(weaver.isInScope(AccessDevScope.scopeName), isTrue);
      expect(weaver.isRegistered<DevAPI>(), isTrue);
    });

    test('Should unregister Dev scope objects when switching to Admin scope', () async {
      await weaver.enterScope(AccessScope.dev());
      expect(weaver.isRegistered<DevAPI>(), isTrue);

      await weaver.enterScope(AccessScope.admin(adminKey: 'new-admin', id: 99));

      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);
      expect(weaver.isRegistered<DevAPI>(), isFalse);

      expect(weaver.isInScope(AccessAdminScope.scopeName), isTrue);
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
      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);

      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.isInScope(AccessAdminScope.scopeName), isTrue);
      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 50));
      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessUserScope.scopeName), isTrue);
    });

    test('Should only have one child scope active at a time', () async {
      await weaver.enterScope(AccessScope.admin(adminKey: 'key', id: 1));
      expect(weaver.isInScope(AccessAdminScope.scopeName), isTrue);
      expect(weaver.isInScope(AccessUserScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);

      await weaver.enterScope(AccessScope.user(userId: 10));
      expect(weaver.isInScope(AccessAdminScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessUserScope.scopeName), isTrue);
      expect(weaver.isInScope(AccessPublicScope.scopeName), isFalse);
      expect(weaver.isInScope(AccessDevScope.scopeName), isFalse);
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
  });
}
