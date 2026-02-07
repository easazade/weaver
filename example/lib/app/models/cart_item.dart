import 'package:dart_mappable/dart_mappable.dart';
import 'shoe.dart';

part 'cart_item.mapper.dart';

@MappableClass()
class CartItem with CartItemMappable {
  final String shoeId;
  final String size;
  final int quantity;
  final Shoe? shoe; // Optional reference to full shoe data

  CartItem({
    required this.shoeId,
    required this.size,
    this.quantity = 1,
    this.shoe,
  });

  double get totalPrice {
    if (shoe == null) return 0.0;
    return shoe!.price * quantity;
  }
}
