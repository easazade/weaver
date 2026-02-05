import '../api/user_api.dart';
import 'user_cubit.dart';

class LoginCubit {
  final UserApi _userApi;
  final UserCubit _userCubit;

  LoginCubit(this._userApi, this._userCubit);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;

    try {
      if (username.isEmpty || password.isEmpty) {
        _error = 'Please enter both username and password';
        return false;
      }

      final user = await _userApi.login(username, password);
      if (user != null) {
        await _userCubit.login(username, password);
        return true;
      } else {
        _error = 'Invalid credentials';
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void clearError() {
    _error = null;
  }
}
