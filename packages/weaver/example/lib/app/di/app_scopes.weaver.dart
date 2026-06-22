// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_string_interpolations, unused_field, prefer_final_parameters

part of 'app_scopes.dart';

class BaseAuthScopeArgs {}

class AuthUserLoggedInScope extends Scope<BaseAuthScopeArgs> {
  static const String scopeName = 'auth-user-logged-in';

  AuthUserLoggedInScope()
    : super(name: "auth-user-logged-in", args: BaseAuthScopeArgs());
}

class AuthLoggedOutScope extends Scope<BaseAuthScopeArgs> {
  static const String scopeName = 'auth-logged-out';

  AuthLoggedOutScope()
    : super(name: "auth-logged-out", args: BaseAuthScopeArgs());
}

class AuthScope {
  AuthScope._();

  static AuthUserLoggedInScope userLoggedIn() => AuthUserLoggedInScope();

  static AuthLoggedOutScope loggedOut() => AuthLoggedOutScope();

  static String get userLoggedInScopeName => "auth-user-logged-in";
  static String get loggedOutScopeName => "auth-logged-out";
}

class AuthScopeHandler extends SwitchScopeHandler<BaseAuthScopeArgs> {
  AuthScopeHandler(super.weaver, {super.changeScopeStream, super.defaultScope});

  final _scopeHandlerDelegate = _AuthScope();
  final _allScopeNames = ['auth-user-logged-in', 'auth-logged-out'];

  @override
  String get scopeName => 'auth';

  @override
  bool canHandleScope(String scopeName) => _allScopeNames.contains(scopeName);

  @override
  Future<void> onEnterScopeByScope(Scope<dynamic> scope) async {
    if (scope.name == 'auth-user-logged-in') {
      await _scopeHandlerDelegate.onEnter(weaverInstance);
    }

    if (scope.name == 'auth-logged-out') {
      await _scopeHandlerDelegate.onLogout(weaverInstance);
    }
  }

  @override
  Future<void> onLeaveScopeByName(String name) async {
    // no methods are annotated with @OnLeaveScope in the scope handler delegate for
    // custom disposal and unregistering of the dependencies registered for this scope
    weaverInstance.unregisterDependenciesRegisteredByThisProxy();
  }
}

extension AuthScopeOnWeaverAddedToWeaver on Weaver {
  AuthScopeOnWeaver get authScope =>
      AuthScopeOnWeaver(ScopeHandlerWeaverProxy(this));
}

class AuthScopeOnWeaver {
  final ScopeHandlerWeaverProxy weaverInstance;

  final _scopeHandlerDelegate = _AuthScope();

  AuthScopeOnWeaver(this.weaverInstance);

  bool get isUserLoggedIn => weaverInstance.isInScope("auth-user-logged-in");
  bool get isLoggedOut => weaverInstance.isInScope("auth-logged-out");

  Scope<BaseAuthScopeArgs>? get currentScope {
    final matches = weaverInstance.scopes.whereType<Scope<BaseAuthScopeArgs>>();
    return matches.firstOrNull;
  }

  @Deprecated('Use ensureEnterScope() method instead')
  Future<Scope<BaseAuthScopeArgs>> awaitEnterScope() => ensureEnterScope();

  /// This method can be used to wait and ensure for enter scope.
  /// If scope has already entered Returns current scope.
  Future<Scope<BaseAuthScopeArgs>> ensureEnterScope() async {
    final matches = weaverInstance.handlers.whereType<AuthScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to await entering a scope without a handler class registered. '
        'Please register an instance of AuthScopeHandler first before calling awaitEnterScope()',
      );
    }

    final handler = matches.first;
    return handler.ensureEnterScope();
  }

  Stream<Scope<BaseAuthScopeArgs>?> get stream {
    final matches = weaverInstance.handlers.whereType<AuthScopeHandler>();
    if (matches.isEmpty) {
      throw WeaverException(
        'Tried to listen on stream of auth switch-scope without a handler class registered. '
        'Please register an instance of AuthScopeHandler first before trying to listen to its stream',
      );
    }

    final handler = matches.first;
    return handler.stream;
  }
}
