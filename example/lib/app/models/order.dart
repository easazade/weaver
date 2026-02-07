import 'package:dart_mappable/dart_mappable.dart';
import 'order_item.dart';

part 'order.mapper.dart';

@MappableClass()
class Order with OrderMappable {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final OrderStatus status;
  final String? shippingAddress;
  final String? paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.shippingAddress,
    this.paymentMethod,
  });
}

@MappableEnum()
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}
