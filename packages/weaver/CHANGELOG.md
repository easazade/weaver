## 0.4.0

- Add feature to generate custom getters on weaver.named for named dependency objects
- Add annotations @WeaverScope, @NamedDependency
- Add feature to register named dependency
- Add tests for named objects registration and fetching
- Remove pubspec.lock
- Update Weaver.reset method to dispose all scope-handlers first before removing them
- fix Weaver and ScopeHandler not awaiting onLeave, onEntered and handle method calls
- Fix incorrect documentation

## 0.3.0

- Add ScopeHandler
- Remove WeaverScope

## 0.2.1

- Add `registerLazy` method
- Refactor class names

## 0.1.1

- Add WeaverScope
- Add Weaver class
- Add tests
- Add RequireDependencies widget
