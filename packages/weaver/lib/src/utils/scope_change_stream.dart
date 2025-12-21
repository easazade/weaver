import 'dart:async';

import 'package:weaver/src/base/scope.dart';

class ScopeChangeStream {
  ScopeChangeStream(final Stream<ScopeState> stream, final ScopeState initialState) {
    _controller = StreamController<ScopeState>.broadcast();
    _currentScopeState = initialState;
    _controller.addStream(stream);
  }

  late StreamController<ScopeState> _controller;

  ScopeState? _currentScopeState;

  Stream<ScopeState> get stream async* {
    if (_currentScopeState != null) yield _currentScopeState!;
    yield* _controller.stream;
  }

  void add(final ScopeState value) {
    _currentScopeState = value;
    _controller.add(value);
  }
}
