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

When it comes to dependency injection, usually dependency objects are required to exists as long as the app is running. But sometimes it is required for a dependency object to only exist within a the duration of a lifecycle.

For example in an application it might make sense to only register some objects after user is authenticated and unregister them after user is logged out. Hence it can be said those dependency objects only live within the authentication-scope.

With weaver it is possible to define a scope by extending `WeaverScope` and registering it.

```dart
class AuthScope extends WeaverScope {
  @override
  final String name = 'auth-scope';

  @override
  final ValueNotifier<bool> isInScope = ValueNotifier(false);

  final Stream<AuthState> authBlocChanges;

  StreamSubscription? _authChangesSubscription;

  AuthScope({required this.authBlocChanges }) {
    _authChangesSubscription = authBlocChanges.listen((final authState) {
        isInScope.value = authState is Authenticated;
    });
  }

  @override
  Future<void> register(final Weaver weaver) async {
    weaver.register(ProductsBloc());
  }

  @override
  Future<void> unregister(final Weaver weaver) async {
    weaver.unregister(ProductsBloc());
  }

  @override
  void dispose() {
    _authChangesSubscription?.cancel();
  }
}
```

After defining the scope, it is required to register in weaver.

```dart
weaver.registerScope(AuthScope());
```

By updating the `isInScope` value the dependencies handled by the above scope will be updated. If value of `isInScope` will be set to true `register` callback will be called to register dependencies of this scope. If value of `isInScope` will be set to false `unregister` callback will be called to unregister the dependencies handled by this scope.

#### Listen for changes in dependencies

All registerations and unregisterations can be listened to by adding a listener on `weaver`

```dart
weaver.addListener() { 
    if(weaver.isRegistered<UserBloc>()){
        // ...
    }
}
```

#### Testing
For testing purposes it is possible to allow re-registration of objects by setting `allowReassignment` to true.

It is also possible to `weaver.reset()` to clear all registered dependencies and scopes. 