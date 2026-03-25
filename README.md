<p align="center">
  <img alt="Pub Likes" src="https://img.shields.io/pub/likes/weaver?style=flat-square">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/easazade/weaver?style=flat-square">
  <!-- <img alt="GitHub Forks" src="https://img.shields.io/github/forks/easazade/weaver?style=flat-square"> -->
  <!-- <img alt="GitHub Watchers" src="https://img.shields.io/github/watchers/easazade/weaver?style=flat-square"> -->
  <!-- <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/easazade/weaver?style=flat-square"> -->
  <!-- <img alt="GitHub Issues" src="https://img.shields.io/github/issues/easazade/weaver?style=flat-square"> -->
  <!-- <img alt="GitHub Pull Requests" src="https://img.shields.io/github/issues-pr/easazade/weaver?style=flat-square"> -->
  <img alt="GitHub Last Commit" src="https://img.shields.io/github/last-commit/easazade/weaver?style=flat-square">
  <img alt="Pub Publisher" src="https://img.shields.io/pub/publisher/weaver?style=flat-square">
  <img alt="GitHub License" src="https://img.shields.io/github/license/easazade/weaver?style=flat-square">
  <!-- <img alt="GitHub Language" src="https://img.shields.io/github/languages/top/easazade/weaver?style=flat-square"> -->
  <!-- <img alt="GitHub Code Size" src="https://img.shields.io/github/languages/code-size/easazade/weaver?style=flat-square"> -->
  <img alt="Codecov" src="https://codecov.io/gh/easazade/weaver/branch/main/graph/badge.svg">
</p>

<img src="https://raw.githubusercontent.com/easazade/weaver/903913b10f02494d4bf12326b1e279b55d0fb80f/logo-banner.png">

Dependency Injection library, rethought and tailored for Flutter. ⚡️

# Why Weaver? 🎯

Dependency injection logic often becomes intertwined with other types of code (state management, UI, etc.), making it difficult to manage and maintain. Weaver isolates dependency injection into its own architectural layer. Object registration, lifecycle management, and dependency resolution live separately from other parts of your codebase. This separation keeps your DI logic clean, focused, and independent—making your architecture more maintainable and your code easier to test.

# Features ✨

These features set Weaver apart from typical service-locator DI libraries:

- ⏳ **Get objects asynchronously:** Wait for objects to be created and retrieve them as soon as they are available.
- 🧠 **Safe widget builds:** Build widgets that wait for their dependencies before rendering. No more `ProviderNotFoundException`.
- 📦 **Scopes:** Register objects globally or only for the lifetime of a defined scope.
- 🔀 **Switch scopes:** Mutually exclusive child scopes under one parent; only one is active, and switching cleans up the previous one—useful for auth modes (guest, user, admin).
- 🗂️ **Sessions:** Group related dependencies created during a workflow and clear them together. Code generation optional for a type-safe API.
- 🏷️ **Named dependencies:** Optional code generation for quick, readable access to multiple instances of the same type.

# Install 📦

Add the following dependencies to `pubspec.yaml` ⬇️

```yaml
dependencies:
  weaver: ^0.9.2 # Dart-only projects
  flutter_weaver: ^0.9.2 # Flutter projects (re-exports weaver + widgets)

dev_dependencies:
  build_runner:
  weaver_builder: ^0.9.2
```

# Getting started 🚀

Import the library: in Flutter use `package:flutter_weaver/flutter_weaver.dart`; in Dart-only code use `package:weaver/weaver.dart`. The global `weaver` instance is ready to use.

Register objects 🧰

```dart
weaver.register(UserRepository());
weaver.registerLazy(() => UserBloc(userRepository: weaver.get()));

weaver.registerIfIsNot(CartSession(cartService: weaver.get()));
```

And then get them anywhere in your code 🔍

```dart
final userBloc = weaver.get<UserBloc>();
```

**Note:** Type inference works too. Just omit the type argument when the left-hand side is explicit:

```dart
final UserBloc userBloc = weaver.get();
```

# Usage 🧭

## Safely build widget 🛠️

The `RequireDependencies` widget waits for specified dependency objects to be registered elsewhere and become available. Once those dependencies are ready, it automatically rebuilds the widget tree.

`RequireDependencies` lets you list the type of objects you need, then rebuilds when those registrations appear. It does not care when, where, or how they were registered.

```dart
RequireDependencies(
    weaver: weaver,
    dependencies: const [DependencyKey(type: UserBloc), DependencyKey(type: ProductsBloc)],
    builder: (context, child, isReady) {
        if (isReady) {
            // When isReady is true, both UserBloc & ProductsBloc are now registered and available
            // ProductsPage can now safely call weaver.get<UserBloc>() & weaver.get<ProductsBloc>()
            return const ProductsPage();
        } else {
            return const CircularProgressIndicator();
        }
    },
)
```

Unlike `Provider` or `BlocProvider`, where you must explicitly define and create the required object inside the widget tree to make it available to descendants (e.g., using `context.read<T>()` or `BlocBuilder`), `RequireDependencies` is completely decoupled from where or how your objects are registered. Whether an object is registered globally, within a session, or inside a specific scope using Weaver's methods, this widget doesn't need to know the registration details—it just reacts to them.

This provides a significant advantage over traditional dependency injection approaches: it bridges the gap between a standalone DI container and Flutter's reactive nature. Instead of manually checking if an object is ready or handling registration timing in your business logic, `RequireDependencies` takes on that single responsibility. It ensures your widget tree is safely built only when its dependencies are available, eliminating `ProviderNotFoundException` errors and the architectural headache of nesting providers at the "correct" level of the widget tree.

## Get objects asynchronously ⏱️

You can wait until a type is registered with `getAsync()` and resolve it as soon as it is registered.

```dart
// registers UserBloc 2 seconds later
Future.delayed(const Duration(seconds: 2), (){
    weaver.register(UserBloc());
});

// below line will get userBloc as soon as it is registered. In this case 2 seconds later
final userBloc = await weaver.getAsync<UserBloc>();
```

**Note:** For widgets, prefer `RequireDependencies` over `getAsync()` so the tree stays declarative.

## Named Dependencies 🏷️

Weaver allows registering named instances of the same type of object.

```dart
weaver.register<String>(token, name: 'auth-token');
weaver.register<String>(userId, name: 'user-id');
```

```dart
// fetch named objects using their name
final authToken = weaver.get<String>(name: 'auth-token');
final userId = weaver.get<String>(name: 'user-id');
```

To make things simpler Weaver can code generate named dependency objects. This way it is possible to register multiple objects of the same type for different purposes.

```dart
@NamedDependency(name: 'user-profile')
Profile _userProfile() {
  // write code to return a user profile object
  return profile;
}

@NamedDependency(name: 'admin-profile')
Profile _adminProfile() {
  // write code to return an admin profile object
  return profile;
}
```

After `dart run build_runner build`, Weaver gets generated getters for each named dependency, which keeps access readable when you have several instances of the same type.

```dart
final userProfile = weaver.named.userProfile;
final adminProfile = weaver.named.adminProfile;
```

## Scoped Dependencies 🧩

Often dependencies should live for the whole app run; sometimes they should exist only in a particular scenario or lifecycle phase. A **scope** is that boundary: register on enter, unregister on leave. You choose what the boundary means (signed-in user, route, feature flag, and so on).

For example, you might register certain types only after login and tear them down on logout—those types “live” in an authentication-related scope (`AuthenticationScope`, `AccessLevelScope`, `ProfileRouteScope`, or whatever you name it).

Weaver lets you define scopes with their own dependencies; those types become available whenever that scope is active.

```dart
@WeaverScope(name: 'admin-scope')
class _AdminScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int adminId, String adminAccessLevel) async {
    // register dependencies here
    weaver.register(AdminBloc(id: adminId, accessLevel: adminAccessLevel));
  }
}
```

Then run `dart run build_runner build` in your project. It generates an `AdminScopeHandler` and an `AdminScope` class.

**Notes:**

1. In `@OnEnterScope`, the first parameter must be `Weaver`; add any extra parameters you need after it. They become fields on the generated `AdminScope` type.
2. If you omit `@OnLeaveScope`, the generated handler unregisters whatever you registered in `@OnEnterScope`. If you add `@OnLeaveScope`, you must unregister (or dispose) those registrations yourself; `@NamedDependency` fields are still unregistered by generated code unless you set `autoDispose: false`.

```dart
@WeaverScope(name: 'admin-scope')
class _AdminScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int adminId, String adminAccessLevel) async {
    // register dependencies here
    weaver.register(AdminBloc(id: adminId, accessLevel: adminAccessLevel));
  }

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaver) async {
    // Optional: perform custom disposal or actions before unregistering
    // If you don't add this method, Weaver automatically handles unregistering
    weaver.unregister<AdminBloc>();
  }
}
```

## Entering and leaving a scope 🚪

Register the generated handler with the same `Weaver` instance you use everywhere else:

```dart
weaver.addScopeHandler(AdminScopeHandler(weaver));
```

Enter the scope by passing the generated args object. That runs your `@OnEnterScope` method and registers dependencies.

```dart
await weaver.enterScope(
  AdminScope(adminId: 24, adminAccessLevel: 'editor'),
);
```

### Checking whether a scope is active

You can ask whether a given scope is currently entered:

```dart
final isInScope = weaver.adminScope.isIn;
// will return true if weaver has entered AdminScope
```

To leave, call `leaveScope` with that scope’s name:

```dart
weaver.leaveScope(AdminScope.scopeName);
```

### Automatic enter and leave via `changeScopeStream` 🔄

Often the correct scope is already determined elsewhere: auth state, the active account type, a session object, a BLoC, and so on. Repeating `if` / `enterScope` / `leaveScope` in every listener is easy to get wrong (for example leaving a scope too late or not at all).

The generated scope handler accepts an optional **`changeScopeStream`**: a **`Stream<Scope<…>?>`** that tells Weaver what should be active **for that handler**:

- **Non-null scope** — Weaver **enters** that scope using the same logic as `weaver.enterScope(...)`.
- **`null`** — The handler **leaves** the scope it currently tracks, same idea as calling `weaver.leaveScope(...)` for that scope’s name.

You map your existing stream (store, `Stream`, etc.) into `Scope?` values once, when registering the handler.

**Example:**

```dart
weaver.addScopeHandler(
  AdminScopeHandler(
    weaver,
    changeScopeStream: authBloc.stream.map((state) {
      if (state.authenticatedUser.isAdmin) {
        return AdminScope(
          adminId: state.authenticatedUser.id,
          adminAccessLevel: state.authenticatedUser.accessLevel,
        );
      }
      return null;
    }),
  ),
);
```

While the user is an admin, each matching event keeps the admin scope active; when they are not (or log out), emitting `null` leaves the scope.

**Why this helps:** One source of truth keeps DI boundaries aligned with app state, less duplicated branching, and fewer places that must remember to call `leaveScope` when conditions change. 

## Listen for scope changes 👂

The generated scope extension (e.g. `weaver.authScope`) has a `stream` property that can be used to listen for scope changes when needed. The stream emits the current scope when entering and `null` when leaving, so you can react to scope lifecycle changes in your application.

```dart
weaver.authScope.stream.listen((scope) {
  if (scope != null) {
    // Scope was entered
  } else {
    // Scope was left
  }
});
```

## Define named dependencies for scopes 🗂️

In weaver it is possible to define named dependencies specific to a scope.

```dart
@WeaverScope(name: 'my-scope')
class _MyScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int argument1, String argument2) async {
    // if you register a dependency here no named getter will be generated for it.
  }

  // A getter will be generated for this dependency
  // Registration and un-registration are handled automatically by Weaver
  @NamedDependency(name: 'my-component')
  MyComponent1 _myComponent1() =>  MyComponent1(...);

  // A getter will be generated for this dependency
  // Registration and un-registration are handled automatically by Weaver
  @NamedDependency(name: 'my-component-2')
  MyComponent2 _myComponent2() =>  MyComponent2(...);

  // @OnLeaveScope is optional - if you don't add it, Weaver automatically handles unregistering
  // all named dependencies when the scope is left
}
```

**Important:** Named dependencies on the scope class are registered and unregistered by generated code. To own teardown yourself, set `autoDispose: false` on `@NamedDependency` and handle unregister (or disposal) in `@OnLeaveScope`.

To access the named dependencies generated for a scope:

```dart
if (weaver.myScope.isIn) {
  final component1 = weaver.myScope.myComponent1;
  final component2 = weaver.myScope.myComponent2;
}
```

## AutoScope Widget 🎯

When you need a scope tied to a specific route or widget subtree, `AutoScope` automatically manages the scope lifecycle. It enters the scope when the widget mounts and leaves it when the widget is disposed, ensuring dependencies are available only within that widget tree.

This provides similar functionality to Provider's `Provider` widget—making dependencies available to a widget subtree—but with a key architectural advantage: the logic for creating and configuring those dependencies stays outside the widget tree, in your scope handler.

### Simple Example

```dart
AutoScope(
  weaver: weaver,
  scope: ProductDetailScope(productId: 123),
  child: ProductDetailPage(),
)
```

When `AutoScope` mounts (for example when the route is pushed), `ProductDetailScope` is entered; when `AutoScope` is disposed, the scope is left and its dependencies are cleaned up.

### Using AutoScope with RequireDependencies

Combine `AutoScope` with `RequireDependencies` to create a clean separation between scope management and widget implementation. Define the scope in your route configuration, then use `RequireDependencies` in your widgets to safely access scoped dependencies.

Here's how they work together: The **scope** defines which dependencies to register when entered and unregister when left. The **AutoScope widget** manages the scope lifecycle for a widget subtree. It enters the scope when mounted and leaves it when disposed, triggering dependency registration and cleanup automatically for that subtree/route. The **RequireDependencies widget** waits for those dependencies to become available before building its child, ensuring your widgets never try to access dependencies that aren't ready yet. Each component has its own responsibility and is decoupled from the others.

Here's a practical example:

```dart
// Scope definition
@WeaverScope(name: 'product-detail')
class _ProductDetailScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int productId) async {
    weaver.register(ProductBloc(productId: productId));
    weaver.register(CommentBloc(productId: productId));
  }
}

// Route definition
class Routes {
  static Route<dynamic> productDetailRoute(int productId) {
    return MaterialPageRoute(
      builder: (context) => AutoScope(
        weaver: weaver,
        scope: ProductDetailScope(productId: productId), // registers ProductBloc, CommentBloc
        child: const ProductDetailPage(),
      ),
    );
  }
}

// Page widget
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RequireDependencies(
      weaver: weaver,
      dependencies: const [
        DependencyKey(type: ProductBloc),
        DependencyKey(type: CommentBloc),
      ],
      builder: (context, child, isReady) {
        if (isReady) {
          // ProductBloc and CommentBloc are now available
          // They were registered when ProductDetailScope was entered
          final productBloc = weaver.get<ProductBloc>();
          return ProductDetailView(bloc: productBloc);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
```

With this approach, you can:

- Automatically manage scope lifecycle based on widget mount/unmount
- Access scoped dependencies safely using `RequireDependencies` without worrying about registration timing
- Keep dependency creation logic separate from your widget tree—unlike Provider where you create dependencies inline, Weaver keeps this logic in scope handlers, maintaining cleaner architecture
- Define scopes independently and compose them with any widget tree

This separation keeps your dependency injection logic isolated from UI code, making your architecture more maintainable and testable.

## Switch Scopes 🔀

Switch scopes are similar to regular scopes, but they allow you to define a parent scope with multiple child scopes that you can switch between. This is useful when you need to manage different sets of dependencies that are mutually exclusive—only one child scope can be active at a time, and switching to a new child scope automatically removes the dependencies from the previous one.

Unlike regular scopes that have a single `@OnEnterScope` callback, switch scopes have multiple `@OnEnterScope` callbacks, each annotated with a `name` parameter to identify the child scope.

### Defining a Switch Scope

Here's an example of defining a switch scope with multiple child scopes:

```dart
@WeaverSwitchScope(name: 'access')
class _AccessScope {
  @OnEnterScope(name: 'admin')
  Future<void> adminAccess(Weaver weaver, String adminKey, int? id) async {
    weaver.register('admin-key-private');
    weaver.register(AdminAPI(adminKey: adminKey, id: id));
  }

  @OnEnterScope(name: 'user')
  Future<void> userAccess(Weaver weaver, int userId) async {
    weaver.register(UserAPI(userId: userId));
  }

  @OnEnterScope(name: 'public')
  Future<void> publicAccess(Weaver weaver, bool flag) async {
    weaver.register(PublicAPI(flag: flag));
  }

  @OnEnterScope(name: 'dev')
  Future<void> devAccess(Weaver weaver) async {
    weaver.register(DevAPI());
  }
}
```

After running `dart run build_runner build`, Weaver will generate an `AccessScopeHandler` class and an `AccessScope` class with static factory methods for creating each child scope.

### Registering a Switch Scope

After defining the switch scope, you need to register the scope handler with Weaver. You can optionally pass a default scope that will be automatically entered when the handler is registered:

```dart
// Register without a default scope
weaver.addScopeHandler(AccessScopeHandler(weaver));

// Register with a default scope (public scope will be entered automatically)
weaver.addScopeHandler(
  AccessScopeHandler(weaver, defaultScope: AccessScope.public(flag: true)),
);
```

When you register with a default scope, that child scope is immediately entered and its dependencies are registered. If you later leave a current child scope, Weaver will automatically switch back to the default scope.

### Switching Between Child Scopes

To switch between child scopes, use the `enterScope()` method with the desired child scope:

```dart
// Switch to admin scope
await weaver.enterScope(AccessScope.admin(adminKey: 'admin-key-123', id: 42));

// Switch to user scope
await weaver.enterScope(AccessScope.user(userId: 100));

// Switch to public scope
await weaver.enterScope(AccessScope.public(flag: true));

// Switch to dev scope
await weaver.enterScope(AccessScope.dev());
```

### Current child scope

```dart
final currentScope = weaver.accessScope.currentScope;
```

To check for a certain child scope:

```dart
final isInAccessAdminScope = weaver.accessScope.isAdmin;
final isInAccessDevScope = weaver.accessScope.isDev;
```

### Awaiting Scope Entry

The `ensureEnterScope()` method allows you to ensure the scope has been entered. It either returns the current scope immediately (if already in a scope) or waits for a scope to be entered (if no scope is active yet). This is useful when you need to defer navigation or other logic until a scope change has occurred.

For example, in a Splash Screen you might want to wait for the auth scope to be determined before deciding which route to navigate to:

```dart
class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await weaver.authScope.ensureEnterScope();

    if (mounted) {
      if (weaver.authScope.isUserLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }
}
```

- If a scope is already active, `ensureEnterScope()` returns it immediately.
- If no scope is active, it waits until a scope is entered (e.g., via `enterScope()` elsewhere) and then returns the new scope.
- Throws if the switch scope handler is not registered with Weaver.

When you switch to a new child scope, the previous child is left first: its dependencies are unregistered, then the new child’s `@OnEnterScope` runs and its dependencies are registered.

### Custom `@OnLeaveScope` callbacks

You can optionally add custom `@OnLeaveScope` callbacks for each child scope to perform cleanup or custom disposal before the dependencies are removed:

```dart
@WeaverSwitchScope(name: 'access')
class _AccessScope {
  // … other @OnEnterScope methods

  @OnEnterScope(name: 'user')
  Future<void> userAccess(Weaver weaver, int userId) async {
    weaver.register(UserAPI(userId: userId));
  }

  @OnLeaveScope(name: 'user')
  Future<void> userCleanUp(Weaver weaver) async {
    // Custom cleanup for user scope
    final userAPI = weaver.get<UserAPI>();
    await userAPI.dispose();
    weaver.unregister<UserAPI>();
  }
}
```

If you don't provide an `@OnLeaveScope` callback for a child scope, Weaver will automatically handle unregistering the dependencies when switching away from that scope.

## Sessions 📦

While scopes manage dependencies based on application lifecycle (entering and leaving specific states), sessions provide a way to group related dependencies that are created dynamically as your code executes. Sessions are particularly useful when you have a collection of objects that belong together and need to be cleared all at once when a particular operation or workflow completes.

Unlike scopes, which are tied to lifecycle events, sessions allow you to register dependencies incrementally as your application logic progresses, and then remove them collectively when they're no longer needed. This makes sessions ideal for managing temporary dependencies that are related to a specific user action, workflow, or operation.

For example, imagine a shopping cart checkout workflow where state management components and services are created incrementally as the user progresses. When the user adds items to their cart and proceeds to checkout, you might need to register a `ShippingBloc` to handle shipping option selection, a `DiscountApi` to manage discount code validation, or a `CheckoutBloc` to orchestrate the checkout process. These components are related to this specific checkout session and should be cleared together when the checkout is completed or abandoned. This is where sessions shine.

### Using Sessions

You can register dependencies with a session name using the `session` parameter:

```dart
// Register state management components and services under a session as workflow progresses
// User adds item to cart and proceeds to shipping selection
weaver.register(ShippingBloc(shippingApi: weaver.get()), session: 'checkout');

// User applies a discount code
weaver.register(DiscountApi(discountService: weaver.get()), session: 'checkout');

// User proceeds to final checkout step
weaver.register(CheckoutBloc(
  shippingBloc: weaver.get(),
  discountApi: weaver.get(),
), session: 'checkout');

// Later, clear all dependencies belonging to the 'checkout' session
weaver.clearSession('checkout');
```

When you call `clearSession()`, all dependencies registered under that session name will be removed, while dependencies registered without a session or under different sessions remain untouched.

```dart
// Register some components with a session
weaver.register(ShippingBloc(shippingApi: weaver.get()), session: 'checkout');
weaver.register(DiscountApi(discountService: weaver.get()), session: 'checkout');

// Register other dependencies without a session (or with a different session)
weaver.register(UserProfileBloc());
weaver.register(SettingsBloc(), session: 'user-settings');

// Clear only the checkout session
weaver.clearSession('checkout');

// ShippingBloc and DiscountApi are now removed
// UserProfileBloc and SettingsBloc remain registered
```

### Session Extensions (Code Generation)

To make working with sessions more convenient and type-safe, Weaver can generate extension methods for your sessions. This provides a cleaner API for registering and clearing session-specific dependencies.

Define a session using the `@WeaverSession` annotation:

```dart
@WeaverSession(name: 'checkout')
// ignore: unused_element
class _CheckoutSession {}
```

After running `dart run build_runner build`, Weaver will generate extension methods that provide easy access to session operations:

```dart
// Register state management components using the generated extension
// As the user progresses through checkout workflow
weaver.checkoutSession.register(ShippingBloc(shippingApi: weaver.get()));
weaver.checkoutSession.register(DiscountApi(discountService: weaver.get()));
weaver.checkoutSession.register(CheckoutBloc(
  shippingBloc: weaver.get(),
  discountApi: weaver.get(),
));

// Clear all dependencies in the checkout session
weaver.checkoutSession.clear();
```

The generated extension provides:

- A `register<T>()` method that automatically associates dependencies with the session
- A `clear()` method that removes all dependency objects belonging to that session

This approach makes your code more readable and less error-prone, as you don't need to remember session names as strings. The generated code ensures type safety and provides a consistent API for managing session-based dependencies.

# Observing registration changes 👀

`addObserver` runs your callback after registrations change (register, unregister, session clear, scope-driven unregisters, etc.). Use it to react to the container’s contents.

```dart
weaver.addObserver(() {
  if (weaver.isRegistered<UserCubit>()) {
    // ...
  }
});
```

# Testing 🧪

For tests you can:

- Set `allowReassignment` to `true` to replace existing registrations and handlers.
- Set `allowScopesWithoutHandler` to `true` so `enterScope` does not throw when no handler is registered.
- Call `weaver.reset()` to clear registrations and scope state.
