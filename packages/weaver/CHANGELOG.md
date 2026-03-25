## 0.9.3

- Add `Weaver.registerIfAbsent`; deprecate `registerIfIsNot` (same behavior).
- `DependencyKey` constructor is `const`.
- Simplify and improve API & Add more code comments

## 0.9.2

- Update docs
- Add missing doc on awaitEnterScope() method
- Add feature to pass scope changes from an input stream argument passed to scope-handler class
- Fix bug in base ScopeHandler class
- Expose a stream of scope changes from ScopeHandler class
- Add tests for ensureEnterScope method in ScopeHandler class
- Move ensureEnterScope to base ScopeHandler class
- Change method name awaitEnterScope to ensureEnterScope

## 0.9.1

- Bump LICENSE year
- Remove shorthand functions inject() & injectAsync() to avoid production or error prone code when weaver proxies are being used behind the scenes
- Add tests for awaitEnterScope() method
- Add feature to wait for enter scope for generated scopes
- Fix notifyObservers() not being called when a session was cleared
- Add allowScopesWithoutHandler flag in Weaver class for testing
- Add currentScope method to generated switch scope extension class on weaver

## 0.9.0

- Add document for switch scope feature
- Update SwitchScopeWriter to not support generating short-hand getters for @NamedDependency annotated methods
- Move ownership of scopes to ScopeHandler which is the unit responsible for managing them
- Add switch scope handler feature
- abstract away ScopeHandler
- Cleanup code for ScopeHandler class and remove unused code
- Add more tests
- Add canHandleScope method to ScopeHandler base class and Update Weaver
- Update syntax validation for classes annotated with @WeaverScope annotation
- Update annotations to retrofit multi state scopes feature

## 0.8.2

- Adds injectAsync method to Weaver class
- Adds Documentation comments
- Updates README

## 0.8.1

- Add `inject` function
- Add `registerIfIsNot` method to `Weaver` class

## 0.8.0

- Add feature to make @OnLeaveScope annotation optional & make generated scope handlers to automatically unregister objects when scope is left
- Fix bugs in unregister & isRegistered methods & add more tests
- Fix errors, typos in and update README

## 0.7.1

- Update documents
- Add session feature
- Add ability for code generated session objects on weaver using @WeaverSession annotation
- Clean up weaver and Fix bugs, Add more tests

## 0.6.2

- Fix docs

## 0.6.1

- Fix repository links in pubspec.yaml file

## 0.6.0

- Update & Fix Documentation
- Move flutter code into flutter_weaver
- Add more tests
- Fix unregister method not unregistering only by name
- Fix bug causing isRegistered method to return false sometimes when dependency was registered
- Update exception logs
- Update `weaver.enterScope()` method to throw exception if there is no scope-handler registered
- Fix bugs in builder generating incorrect code and typos
- Add validation check for NamedDependency annotations inside @WeaverScope annotation
- Update file headers

## 0.5.0

- Update documentation
- Improve error message when user tries to retrieve a registered named object without passing the name
- Update builder to support generating named dependency getters on weaver for defined scopes

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
