import 'package:dart_mappable/dart_mappable.dart';

part 'shoe.mapper.dart';

@MappableClass()
class Shoe with ShoeMappable {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final List<String> imageUrls;
  final List<String> sizes;
  final Map<String, int> stockBySize; // size -> quantity available
  final String? category;

  Shoe({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.imageUrls = const [],
    this.sizes = const [],
    this.stockBySize = const {},
    this.category,
  });

  bool get isInStock => stockBySize.values.any((quantity) => quantity > 0);
  
  int getStockForSize(String size) => stockBySize[size] ?? 0;
}
