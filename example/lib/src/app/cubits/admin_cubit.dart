import '../api/admin_api.dart';
import '../models/shoes.dart';

class AdminCubit {
  final AdminApi _adminApi;

  AdminCubit(this._adminApi);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Shoes> addShoes(Shoes shoes) async {
    _isLoading = true;
    try {
      return await _adminApi.addShoes(shoes);
    } finally {
      _isLoading = false;
    }
  }

  Future<List<Shoes>> getAllShoes() async {
    _isLoading = true;
    try {
      return await _adminApi.getAllShoes();
    } finally {
      _isLoading = false;
    }
  }
}
