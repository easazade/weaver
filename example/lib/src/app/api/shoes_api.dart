import '../models/shoes.dart';

class ShoesApi {
  // Mock data for testing
  final List<Shoes> _shoes = [
    Shoes(
      id: '1',
      name: 'Running Shoes',
      description: 'Comfortable running shoes for daily use',
      price: 99.99,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Shoes(
      id: '2',
      name: 'Basketball Shoes',
      description: 'High-performance basketball shoes',
      price: 129.99,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Shoes(
      id: '3',
      name: 'Casual Sneakers',
      description: 'Stylish casual sneakers',
      price: 79.99,
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  Future<List<Shoes>> getShoes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_shoes);
  }

  Future<Shoes> addShoes(Shoes shoes) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _shoes.add(shoes);
    return shoes;
  }

  Future<Shoes?> getShoesById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _shoes.firstWhere((shoes) => shoes.id == id);
    } catch (e) {
      return null;
    }
  }
}
