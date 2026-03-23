## 0.9.2

- Bump [weaver](https://pub.dev/packages/weaver) to 0.9.2
- Fix generated scopes not overriding equals & hashCode
- Update weaver_writer to generate stream extensions
- Update generated scope extensions to expose the stream of scope handler

## 0.9.1

- Bump LICENSE year
- Bump [weaver](https://pub.dev/packages/weaver) to 0.9.1

## 0.9.0

- Update SwitchScopeWriter to not support generating short-hand getters for @NamedDependency annotated methods
- Clean up and organize code generation logic into writer functions.
- change weaver property in scope handlers to weaverInstance to avoid conflict with global weaver
- Separate weaver scope annotations into @WeaverScope & @WeaverSwitchScope
- Bump [weaver](https://pub.dev/packages/weaver) to 0.9.0
- Fix bugs in code generation
- Fix generated getter extension for scopes on Weaver having incorrect naming
- Fix syntax validation on WeaverScope not throwing when multiple child scopes have duplicate names

## 0.8.2

- Bump [weaver](https://pub.dev/packages/weaver) to 0.8.2

## 0.8.1

- Bump [weaver](https://pub.dev/packages/weaver) to 0.8.1

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
