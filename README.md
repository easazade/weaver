<img src="https://raw.githubusercontent.com/easazade/weaver/903913b10f02494d4bf12326b1e279b55d0fb80f/logo-banner.png">

Dependency Injection library, rethought and tailored for Flutter. ⚡️

## Why Weaver? 🎯

Dependency injection logic often becomes intertwined with other types of code (state management, UI, etc.), making it difficult to manage and maintain. Weaver isolates dependency injection into its own architectural layer. Object registration, lifecycle management, and dependency resolution live separately from other parts of your codebase. This separation keeps your DI logic clean, focused, and independent—making your architecture more maintainable and your code easier to test.

## Features ✨

- ✅ Register objects and get them anywhere in your code by just calling `weaver.get()`.
- ⏳ Ability to wait for an creation of an object before it is even created and then get it as soon as it is created with `getAsync()`.
- 🧠 Build widgets without worrying about whether dependency objects are created or not by using `RequireDependencies` widget. No more ProviderNotFoundException
- 📦 Ability to both register an object where it can live globally or within the lifecycle of defined `Scope` that can be handled by a `ScopeHandler`.
- 📙 Named dependency with generated quick access extension methods on `weaver.named`

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
