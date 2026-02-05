import '../api/user_api.dart';
import '../models/user.dart';

class UserCubit {
  final UserApi _userApi;

  UserCubit(this._userApi);

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<User?> login(String username, String password) async {
    _currentUser = await _userApi.login(username, password);
    return _currentUser;
  }

  Future<void> logout() async {
    await _userApi.logout();
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
}
