import '../api/shoes_api.dart';
import '../models/shoes.dart';

class ShoesCubit {
  final ShoesApi _shoesApi;

  ShoesCubit(this._shoesApi);

  List<Shoes> _shoes = [];
  List<Shoes> get shoes => _shoes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadShoes() async {
    _isLoading = true;
    try {
      _shoes = await _shoesApi.getShoes();
    } finally {
      _isLoading = false;
    }
  }

  Future<Shoes?> getShoesById(String id) async {
    return await _shoesApi.getShoesById(id);
  }
}
