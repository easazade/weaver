Dependency Injection library, rethought and tailored specifically for Flutter.

## Features

- Register objects and get them anywhere in your code by just calling `weaver.get()`.
- Ability to wait for an creation of an object before it is even created and then get it as soon as it is created with `getAsync()`.
- Build widgets without worrying about whether dependency objects are created or not by using `RequireDependencies` widget.
- Ability to both register an object where it can live globally or within the lifecycle of defined `Scope` that can be handled by a     `ScopeHandler`.
- Register objects to be created lazily.

## Install 
Add following dependencies to pubspec.yaml
```yaml
dependencies:
  weaver: ^x.y.z

dev_dependencies:
  build_runner:  
  weaver_builder: ^x.y.z  
```

## Getting started

Register objects

```dart
weaver.register(UserRepository());
weaver.registerLazy(
    () => UserBloc(userRepository: weaver.get())
);
```

And then get them any where in your code

```dart
final userBloc = weaver.get<UserBloc>();
userBloc.doSomething();
```

## Usage

#### Safely build widget

With `RequireDependencies` allows specifying only the type of dependency objects that are required, then build the widget as soon as those dependency objects are created. It's not like the provider or BlocProvider where it is required to first, create and provide the required object in order to be able to use it later. With `RequireDependencies` widget it doesn't matter whether the objects are created or going to be created. When they are ready it will rebuild.

```dart
RequireDependencies(
    weaver: weaver,
    dependencies: const [UserBloc, ProductsBloc],
    builder: (context, child, isReady) {
        if (isReady) {
            // UserBloc and ProductsBloc are used inside
            // build method of ProductsPage
            return const ProductsPage();
        } else {
            return const CircularProgressIndicator();
        }
    },
)
``` 

#### Get objects asynchronously

With weaver it is possible to wait for registration of an object and then get it as soon as it is registered. using `getAsync()` method.

```dart
// registers UserBloc 2 seconds later
Future.delayed(const Duration(seconds: 2), (){
    weaver.register(UserBloc());
});
```

```dart
// below line will get userBloc as soon as it is registered.
final userBloc = await weaver.getAsync<UserBloc>();
```

**NOTE:** When building widgets there is no need to use `getAsync()` method. Please use `RequireDependencies` widget instead.

#### Named Dependencies
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

#### Scoped Dependencies

When it comes to dependency injection, usually dependency objects are required to exists as long as the app is running. But sometimes it is required for a dependency object to exist only in certain scenario or scope of a lifecycle. In short some dependencies only live in certain scopes.

For example in an application it might make sense to only register some dependency objects after user is authenticated and unregister them after user has logged out. Hence it can be said those dependency objects only live within the authentication scope.

With weaver it is possible to define a scope by extending `Scope` class and then define a `ScopeHandler` to handle creation and registering of objects that should exist when weaver enters that scope and unregistering them when weaver leaves that scope.

```dart
@WeaverScope(name: 'my-scope')
class _MyScope {
  @OnEnterScope()
  Future<void> onEnter(Weaver weaver, int argument1, String argument2) async {
    weaver.register(MyDependency(argument1: argument1, argument2: argument2));
  }

  @OnLeaveScope()
  Future<void> onLeave(Weaver weaver) async {
    weaver.unregister<MyDependency>();
  }
}
```
Then run `dart run build_runner build -d` in your code. It will generate a `AuthScopeHandler` & `AuthScope` class.
**NOTES:**
1. In above code, in the method annotated with `@OnEnterScope` you can add as many arguments as you need.

After defining the scope, it is required to register the handler to weaver.

```dart
weaver.addScopeHandler(AuthenticatedScopeHandler());
```

Now whenever the user is authenticated, weaver can be signaled that application has entered the scope of authenticated. that can be done using the `enterScope()` method and the `AuthenticatedScope` class defined above.

```dart
  // after user authenticated
  weaver.enterScope(
    MyScope(argument1: 12, argument2: 'value'),
  );
```

Above call will trigger `MyScopeHandler` that you registered that will register an instance of `MyDependency` with passed parameters.

To leave a scope method `leaveScope()` should be used

```dart
weaver.leaveScope(MyScope.scopeName);
```

## Listen for changes in dependencies

All registrations and un-registrations can be listened to by adding a listener on `weaver`

```dart
weaver.addListener() {
    if(weaver.isRegistered<UserCubit>()){
        // ...
    }
}
```

## Testing

For testing purposes it is possible to allow re-registration of objects by setting `allowReassignment` to true.

It is also possible to `weaver.reset()` to clear all registered dependencies and scopes.
