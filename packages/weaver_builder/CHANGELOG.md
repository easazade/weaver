## 0.8.0

- Update builder to make `@OnLeaveScope` annotation optional
- Make unregistering of objects automatically handled by generated scope handlers

## 0.7.1

- Add ability for code generated session objects on weaver using @WeaverSession annotation

## 0.6.0

- Fix bugs in builder generating incorrect code and typos
- Add validation check for NamedDependency annotations inside @WeaverScope annotation
- Update file headers
- Fix named dependencies not being automatically registered when entered scope

## 0.5.0

- Update builder to support generating named dependency getters on weaver for defined scopes

## 0.4.0

- Add feature to generate scopes, scope-handlers, scope-argument classes 
- Add feature to generate extension variable on `weaver.named` for named variables
