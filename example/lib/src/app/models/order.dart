import 'shoes.dart';

class Order {
  final String id;
  final String userId;
  final List<Shoes> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.date,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<Shoes>? items,
    double? total,
    DateTime? date,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      date: date ?? this.date,
    );
  }
}
