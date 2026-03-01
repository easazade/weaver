import 'dart:async';

import 'package:meta/meta.dart';
import 'package:weaver/src/base/scope.dart';
import 'package:weaver/src/base/weaver.dart';

/// ScopeHandler is a class that handles registering and removing dependencies for the scope name or names
/// it is responsible for.
/// [T] is the type of arguments required when entering the scope.
abstract class ScopeHandler<T> {
  ScopeHandler({final Stream<Scope<T>?>? changeScopeStream}) {
    _changeScopeSubscription = changeScopeStream?.listen((final scope) async {
      if (scope == null) {
        if (_currentScope != null) {
          await handle(LeaveScope(scopeName: _currentScope!.name));
        }
      } else {
        if (canHandleScope(scope.name)) {
          await handle(EnterScope(scope));
        } else {
          throw WeaverException(
            'ScopeHandler responsible for "$scopeName" scope received a '
            'scope that it cannot handle ${scope.name}',
          );
        }
      }
    });
  }

  StreamSubscription? _changeScopeSubscription;
  bool canHandleScope(final String scopeName);
  Scope<T>? _currentScope;
  Scope<T>? get currentScope => _currentScope;

  /// The name of the scope this handler manages.
  String get scopeName;

  Completer<Scope<T>> _currentScopeCompleter = Completer();

  final _streamController = StreamController<Scope<T>?>.broadcast();

  late final Stream<Scope<T>?> stream = _streamController.stream;

  /// This method can be used to wait and ensure for enter scope.
  /// If scope has already entered Returns current scope.
  Future<Scope<T>> ensureEnterScope() async {
    if (currentScope != null) {
      return currentScope!;
    } else {
      return _currentScopeCompleter.future;
    }
  }

  set currentScope(final Scope<T>? scope) {
    if (scope != null) {
      final wasCurrentScopeNull = _currentScope == null;
      _currentScope = scope;
      if (wasCurrentScopeNull) {
        _currentScopeCompleter.complete(scope);
      }
      _streamController.add(scope);
    } else {
      _currentScope = null;
      _currentScopeCompleter = Completer();
      _streamController.add(null);
    }
  }

  Future<void> handle(final HandlerEvent event);

  Future<void> clearAllRegisteredObjects();

  @mustCallSuper
  void dispose() {
    _changeScopeSubscription?.cancel();
  }
}
