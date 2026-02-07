import '../models/user.dart';

class UserApi {
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
  Future<User> login(String username) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (username.toLowerCase() == 'admin') {
      return _adminUser;
    }
    return _regularUser;
  }
}
