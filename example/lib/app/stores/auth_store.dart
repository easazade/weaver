import 'package:example/app/api/user_api.dart';
import 'package:example/app/models/user.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'auth_store.crystalline.dart';

@StoreClass()
abstract class _AuthStore extends Store {
  _AuthStore(this.api);
  final UserApi api;

  @SharedData()
  Data<User> get user;

  @override
  Future<void> init() async {
    user.operation = Operation.read;
    final loggedInUser = await api.currentUser();
    if (loggedInUser != null) {
      user.value = loggedInUser;
    }
    user.operation = Operation.none;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      user.failure = Failure('Invalid username and password');
      return;
    } else {
      user.failure = null;
      user.operation = Operation.read;
      publish();

      final userObject = await api.login(username, password);
      user.value = userObject;
      user.operation = Operation.none;
      publish();
    }
  }
}
