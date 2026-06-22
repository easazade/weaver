import 'package:dart_mappable/dart_mappable.dart';
import 'shoe.dart';

part 'order_item.mapper.dart';

@MappableClass()
class OrderItem with OrderItemMappable {
  final String shoeId;
  final String shoeName;
  final String brand;
  final String size;
  final int quantity;
  final double unitPrice;
  final String? imageUrl;

  OrderItem({
    required this.shoeId,
    required this.shoeName,
    required this.brand,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItem.fromShoe(Shoe shoe, String size, int quantity) {
    return OrderItem(
      shoeId: shoe.id,
      shoeName: shoe.name,
      brand: shoe.brand,
      size: size,
      quantity: quantity,
      unitPrice: shoe.price,
      imageUrl: shoe.imageUrls.isNotEmpty ? shoe.imageUrls.first : null,
    );
  }
}
