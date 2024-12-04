Dependency Injection library, rethought and tailored specifically for Flutter.

## Features

- Register objects and get them anywhere in your code by just calling `weaver.get()`.
- Ability to both register an object where it can live globally or within the lifecycle of defined `WeaverScope`.
- Ability to wait for an creation of an object before it is even created and then get it as soon as it is created with `getAsync()`.
- Build widgets without worrying about whether dependency objects are created or not by using `RequireDependencies` widget.
- Register objects to be created lazily.

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
userBloc.getUser();
```

## Usage

#### Safely build widget

With `RequireDependencies` allows specifying only the type of dependency objects that are required, then build the widget as soon as those dependency objects are created. It's not like the provider or BlocProvider where it is required to first, create and provide the required object in order to be able to use it later. With `RequireDependencies` widget it doesn't matter whether the objects are created or going to be created. When they are ready it will rebuild.

```dart
RequireDependencies(
    weaver: weaver,
    dependencies: const [UserBloc, ProductsBloc],
    builder: (context, _, isReady) {
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

// below line will get userBloc as soon as it is registered.
final userBloc = await weaver.getAsync<UserBloc>();
```

**NOTE:** When building widgets there is no need to use `getAsync()` method. Please use `RequireDependencies` widget instead.

#### Scoped Dependencies

When it comes to dependency injection, usually dependency objects are required to exists as long as the app is running. But sometimes it is required for a dependency object to exist only in certain scenario. In short some dependencies only live in certain scopes.

For example in an application it might make sense to only register some objects after user is authenticated and unregister them after user has logged out. Hence it can be said those dependency objects only live within the authentication scope.

With weaver it is possible to define a scope by extending `Scope` class and then define a `ScopeHandler` to handle creation and registering of objects that should exist when weaver enters that scope and unregistering them when weaver leaves that scope.

```dart
class AuthenticatedScope extends Scope<AuthenticatedScopeArgs> {
  AuthenticatedScope({required super.argument}) : super(name: 'authenticated');
}

class AuthenticatedScopeHandler extends ScopeHandler<AuthenticatedScopeArgs> {
  @override
  String get scopeName => 'authenticated';

  @override
  Future<void> onEnterScope(
    final Weaver weaver,
    final AuthenticatedScopeArgs? argument,
  ) async {
    if (argument != null) {
      weaver.register(UserCubit(userId: argument.userId));
    }
  }

  @override
  Future<void> onLeaveScope(final Weaver weaver) async {
    weaver.unregister<UserCubit>();
  }
}

class AuthenticatedScopeArgs {
  AuthenticatedScopeArgs({required this.userId});

  final String userId;
}
```

After defining the scope, it is required to register the handler to weaver.

```dart
weaver.addScopeHandler(AuthenticatedScopeHandler());
```

Now whenever the user is authenticated, weaver can be signaled that application has entered the scope of authenticated. that can be done using the `enterScope()` method and the `AuthenticatedScope` class defined above.

```dart
  // after user authenticated
  weaver.enterScope(
    AuthenticatedScope(
      argument: AuthenticatedScopeArgs(userId: id),
    ),
  );
```

Above call will trigger `AuthenticatedScopeHandler` to register objects.

To leave a scope method `leaveScope()` should be used

```dart
weaver.leaveScope('authenticated');
```

#### Listen for changes in dependencies

All registrations and un-registrations can be listened to by adding a listener on `weaver`

```dart
weaver.addListener() { 
    if(weaver.isRegistered<UserCubit>()){
        // ...
    }
}
```

#### Testing
For testing purposes it is possible to allow re-registration of objects by setting `allowReassignment` to true.

It is also possible to `weaver.reset()` to clear all registered dependencies and scopes. 