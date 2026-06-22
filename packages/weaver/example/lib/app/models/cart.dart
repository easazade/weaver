import 'package:dart_mappable/dart_mappable.dart';
import 'cart_item.dart';

part 'cart.mapper.dart';

@MappableClass()
class Cart with CartMappable {
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.userId,
    this.items = const [],
  });

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => items.isEmpty;
}
