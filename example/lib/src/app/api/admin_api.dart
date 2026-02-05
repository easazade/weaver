import '../models/shoes.dart';
import 'shoes_api.dart';

class AdminApi {
  final ShoesApi _shoesApi;

  AdminApi(this._shoesApi);

  Future<Shoes> addShoes(Shoes shoes) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return await _shoesApi.addShoes(shoes);
  }

  Future<List<Shoes>> getAllShoes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return await _shoesApi.getShoes();
  }
}
