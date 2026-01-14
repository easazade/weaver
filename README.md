<img src="https://raw.githubusercontent.com/easazade/weaver/903913b10f02494d4bf12326b1e279b55d0fb80f/logo-banner.png">

Dependency Injection library, rethought and tailored for Flutter. ⚡️

## Why Weaver? 🎯

Dependency injection logic often becomes intertwined with other types of code (state management, UI, etc.), making it difficult to manage and maintain. Weaver isolates dependency injection into its own architectural layer. Object registration, lifecycle management, and dependency resolution live separately from other parts of your codebase. This separation keeps your DI logic clean, focused, and independent—making your architecture more maintainable and your code easier to test.

## Features ✨

- ✅ Register objects and get them anywhere in your code by just calling `weaver.get()`.
- ⏳ Ability to wait for an creation of an object before it is even created and then get it as soon as it is created with `getAsync()`.
- 🧠 Build widgets without worrying about whether dependency objects are created or not by using `RequireDependencies` widget. No more ProviderNotFoundException
- 📦 Ability to both register an object where it can live globally or within the lifecycle of defined `Scope` that can be handled by a `ScopeHandler`.
- 🏷️ Named dependency with generated quick access extension methods on `weaver.named`

## Install 📦

Add following dependencies to pubspec.yaml ⬇️

```yaml
dependencies:
  weaver: ^x.y.z # for dart only projects
  flutter_weaver: ^x.y.z # for flutter projects

dev_dependencies:
  build_runner:
  weaver_builder: ^x.y.z
```

## Getting started 🚀

Register objects 🧰

```dart
weaver.register(UserRepository());
weaver.registerLazy(() => UserBloc(userRepository: weaver.get())
);
```

And then get them anywhere in your code 🔍

```dart
final userBloc = weaver.get<UserBloc>();
```

## Usage 🧭

#### Safely build widget 🛠️

`RequireDependencies` widget allows specifying the type of dependency objects that are required, then build the widget as soon as those dependency objects are created. It's not like the provider or BlocProvider where it is required to first, create and provide the required object in order to be able to use it later. With `RequireDependencies` widget it doesn't matter whether the objects are created or going to be created. When they are ready `RequireDependencies` widget will rebuild. No more ProviderNotFoundException or worrying about where it makes sense to add a provider widget in the widget tree.

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

#### Get objects asynchronously ⏱️

With weaver it is possible to wait for registration of an object and then get it as soon as it is registered. using `getAsync()` method.

```dart
// registers UserBloc 2 seconds later
Future.delayed(const Duration(seconds: 2), (){
    weaver.register(UserBloc());
});

// below line will get userBloc as soon as it is registered. In this case 2 seconds later
final userBloc = await weaver.getAsync<UserBloc>();
```

**NOTE:** When building widgets there is no need to use `getAsync()` method. Please use `RequireDependencies` widget instead.

#### Named Dependencies 🏷️

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

After running `dart run builder_runner build` above code will code generate a custom getter in Weaver for this object that allows easier access.
Also the code will be more clear while fetching and using multiple dependencies of the same type.

```dart
final profile = weaver.named.userProfile;
final profile = weaver.named.adminProfile;
```

#### Scoped Dependencies 🧩

When it comes to dependency injection, usually dependency objects are required to exists as long as the app is running. But sometimes it is required for a dependency object to exist only in certain scenario or scope of a lifecycle. In short some dependencies only live in certain scopes.

For example in an application it might make sense to only register some dependency objects after user is authenticated and unregister them after user has logged out. Hence it can be said those dependency objects only live within the authentication scope.

Weaver makes it easy to define scopes that have their own dependencies. These dependencies will become available when weaver enters that scope.

```dart
@WeaverScope(name: 'my-scope')
class _AdminScope {


  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int adminId, String adminAccessLevel) async {
    // register dependencies here
    weaver.register(AdminBloc(id: adminId, accessLevel: adminAccessLevel));
  }

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaver) async {
    // remove registered dependencies that belong to this scope
    weaver.unregister<AdminBloc>();
  }
}
```

Then run `dart run build_runner build -d` in your code. It will generate a `AdminScopeHandler` & `AdminScope` class.
**NOTES:**

1. In above code, in the method annotated with `@OnEnterScope` you can add as many arguments as you need.

#### Entering and Leaving scope 🚪

After defining the scope, it is required to first register the scope-handler class to weaver.

```dart
weaver.addScopeHandler(AdminScopeHandler());
```

weaver can be signaled that application has entered the scope of authenticated. That can be done using the `enterScope()` method and the `AdminScope` class defined above. when weaver enters that scope the method annotated with `@OnEnterScope`in our defined `_AdminScope` class will be called and dependencies will be registered.

```dart
  weaver.enterScope(
    MyScope(argument1: 12, argument2: 'value'),
  );
```

Above call will trigger `AdminScopeHandler` that was registered and annotated method @OnEnterScope will be called with the passed parameters.

##### Check Scope:

It is possible to check whether application has entered a defined scope or not

```dart
final isInScope = weaver.adminScope.isIn;
// will return true if weaver has entered AdminScope
```

To leave a scope `leaveScope()` method should be used

```dart
weaver.leaveScope(MyScope.scopeName);
```

##### Example: 🎯

Here is a practical example of how to enter a scope base on business logic of the application

```dart
weaver.get<AuthBloc>().stream.listen((state){
  // check if should enter admin scope
  if(state.authenticatedUser.isAdmin && !weaver.adminScope.isIn){
    // entering admin scope
    weaver.enterScope(AdminScope(id: 24, accessLevel: 'editor'));
  }else{
    // leaving admin scope
    weaver.leaveScope(AdminScope.scopeName);
  }
})
```

#### Define named dependencies for scopes 🗂️

In weaver it is possible to define named dependencies specific to a scope.

```dart
@WeaverScope(name: 'my-scope')
class _MyScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int argument1, String argument2) async {
    // if you register a dependency here no named getter will be generated for it.
  }

  // A getter will be generated for this dependency
  @NamedDependency(name: 'my-component')
  MyComponent1 _myComponent1() =>  MyComponent1(...);

  // A getter will be generated for this dependency
  @NamedDependency(name: 'my-component-2')
  MyComponent2 _myComponent2() =>  MyComponent2(...);

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaver) async {
    // no need to unregister dependencies annotated with @NamedDependencies. They will be automatically
    // unregistered by scope handler when weaver has left this scope.
  }
}
```

To access the named dependencies generate for a scope:

```dart
if(weaver.myScope.isIn){
  final component1 = weaver.myScope.myComponent1;
  final component2 = weaver.myScope.myComponent2;
}
```

#### AutoScope Widget 🎯

When you need a scope tied to a specific route or widget subtree, `AutoScope` automatically manages the scope lifecycle. It enters the scope when the widget mounts and leaves it when the widget is disposed, ensuring dependencies are available only within that widget tree.

This provides similar functionality to Provider's `Provider` widget—making dependencies available to a widget subtree—but with a key architectural advantage: the logic for creating and configuring those dependencies stays outside the widget tree, in your scope handler.

##### Simple Example

```dart
AutoScope(
  weaver: weaver,
  scope: ProductDetailScope(productId: 123),
  child: ProductDetailPage(),
)
```

When `ProductDetailPage` mounts, `ProductDetailScope` is entered automatically. When the page is removed, the scope is left and its dependencies are cleaned up.

##### Using AutoScope with RequireDependencies

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

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaver) async {
    weaver.unregister<ProductBloc>();
    weaver.unregister<CommentBloc>();
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

#### Sessions 📦

While scopes manage dependencies based on application lifecycle (entering and leaving specific states), sessions provide a way to group related dependencies that are created dynamically as your code executes. Sessions are particularly useful when you have a collection of objects that belong together and need to be cleared all at once when a particular operation or workflow completes.

Unlike scopes, which are tied to lifecycle events, sessions allow you to register dependencies incrementally as your application logic progresses, and then remove them collectively when they're no longer needed. This makes sessions ideal for managing temporary dependencies that are related to a specific user action, workflow, or operation.

For example, imagine a shopping cart checkout workflow where state management components and services are created incrementally as the user progresses. When the user adds items to their cart and proceeds to checkout, you might need to register a `ShippingBloc` to handle shipping option selection, a `DiscountApi` to manage discount code validation, or a `CheckoutBloc` to orchestrate the checkout process. These components are related to this specific checkout session and should be cleared together when the checkout is completed or abandoned. This is where sessions shine.

##### Using Sessions

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

##### Session Extensions (Code Generation)

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

## Observer changes in dependencies 👀

All registrations and un-registrations can be observed to by adding an observer on `weaver`

```dart
weaver.addObserver() {
    if(weaver.isRegistered<UserCubit>()){
        // ...
    }
}
```

## Testing 🧪

For testing purposes it is possible to allow re-registration of objects by setting `allowReassignment` to true.

It is also possible to call `weaver.reset()` to clear all registered dependencies and scopes.
