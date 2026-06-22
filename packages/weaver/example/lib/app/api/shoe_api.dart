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
        'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/311098/10/sv01/fnd/EEA/fmt/png/Softride-Enzo-5-Running-Shoes',
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
        'https://www.tracerindia.com/cdn/shop/files/01_3_c52bf142-d83e-42e7-96f3-5a3ce6bc5c03.jpg?v=1688547156',
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
        'https://www.asics.co.in/media/catalog/product/1/0/1011c127_003_sl_lt.jpg?optimize=high&bg-color=255%2C255%2C255&fit=cover&height=375&width=500&auto=webp&format=pjpg',
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
        'https://www.walkaroo.in/cdn/shop/files/1_29f414dc-dc7b-4267-bc04-0abe240e042d.jpg?v=1753517433',
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

  /// Get all shoes
  Future<List<Shoe>> getAll() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return List.from(_shoes);
  }
}
