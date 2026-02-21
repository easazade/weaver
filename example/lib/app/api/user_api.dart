// ignore_for_file: constant_identifier_names

import 'package:example/app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  UserApi({required this.preferences});

  static const _USERNAME = '__username__';

  final SharedPreferences preferences;

  // Fake user instances
  static final User _regularUser = User(
    id: 'user-1',
    username: 'john_doe',
    firstName: 'John',
    lastName: 'Doe',
  );

  static final User _adminUser = User(
    id: 'admin-1',
    username: 'admin',
    firstName: 'Admin',
    lastName: 'User',
  );

  /// Login method that returns a fixed user.
  /// If username is "admin", returns admin user, otherwise returns regular user.
  Future<User> login(String username, String password) async {
    // Simulate network delay

    if (username.toLowerCase() == 'admin') {
      return _adminUser;
    }
    await preferences.setString(_USERNAME, username);
    return _regularUser.copyWith(username: username);
  }

  Future<User?> currentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final currentUsername = preferences.getString(_USERNAME);
    if (currentUsername == null) {
      return null;
    } else if (currentUsername == 'admin') {
      return _adminUser;
    } else {
      return _regularUser.copyWith(username: currentUsername);
    }
  }

  Future<void> logout() async {
    await preferences.remove(_USERNAME);
  }
}
