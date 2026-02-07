import '../models/shoe.dart';

class ShoeApi {
  // Fake shoe instances
  static final List<Shoe> _shoes = [
    Shoe(
      id: 'shoe-1',
      name: 'Classic Running Shoes',
      brand: 'Nike',
      description: 'Comfortable running shoes for daily use',
      price: 99.99,
      imageUrls: [
        'https://example.com/shoe1-1.jpg',
        'https://example.com/shoe1-2.jpg',
      ],
      sizes: ['7', '8', '9', '10', '11'],
      stockBySize: {'7': 5, '8': 10, '9': 8, '10': 12, '11': 3},
      category: 'Running',
    ),
    Shoe(
      id: 'shoe-2',
      name: 'Basketball High Tops',
      brand: 'Adidas',
      description: 'High-top basketball shoes with excellent ankle support',
      price: 129.99,
      imageUrls: [
        'https://example.com/shoe2-1.jpg',
      ],
      sizes: ['8', '9', '10', '11', '12'],
      stockBySize: {'8': 7, '9': 4, '10': 6, '11': 8, '12': 2},
      category: 'Basketball',
    ),
    Shoe(
      id: 'shoe-3',
      name: 'Casual Sneakers',
      brand: 'Puma',
      description: 'Stylish casual sneakers for everyday wear',
      price: 79.99,
      imageUrls: [
        'https://example.com/shoe3-1.jpg',
        'https://example.com/shoe3-2.jpg',
      ],
      sizes: ['7', '8', '9', '10'],
      stockBySize: {'7': 15, '8': 20, '9': 18, '10': 14},
      category: 'Casual',
    ),
    Shoe(
      id: 'shoe-4',
      name: 'Trail Running Shoes',
      brand: 'Salomon',
      description: 'Durable trail running shoes for off-road adventures',
      price: 149.99,
      imageUrls: [
        'https://example.com/shoe4-1.jpg',
      ],
      sizes: ['8', '9', '10', '11'],
      stockBySize: {'8': 3, '9': 5, '10': 4, '11': 6},
      category: 'Trail Running',
    ),
  ];

  /// Get shoe by ID
  Future<Shoe?> getItemById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      return _shoes.firstWhere((shoe) => shoe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get shoes by list of IDs
  Future<List<Shoe>> getItemsByIds(List<String> ids) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _shoes.where((shoe) => ids.contains(shoe.id)).toList();
  }
}
