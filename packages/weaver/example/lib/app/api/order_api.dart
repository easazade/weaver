import '../models/order.dart';
import '../models/order_item.dart';

class OrderApi {
  // Fake order item instances
  static final List<OrderItem> _orderItems = [
    OrderItem(
      shoeId: 'shoe-1',
      shoeName: 'Classic Running Shoes',
      brand: 'Nike',
      size: '9',
      quantity: 2,
      unitPrice: 99.99,
      imageUrl: 'https://example.com/shoe1-1.jpg',
    ),
    OrderItem(
      shoeId: 'shoe-2',
      shoeName: 'Basketball High Tops',
      brand: 'Adidas',
      size: '10',
      quantity: 1,
      unitPrice: 129.99,
      imageUrl: 'https://example.com/shoe2-1.jpg',
    ),
    OrderItem(
      shoeId: 'shoe-3',
      shoeName: 'Casual Sneakers',
      brand: 'Puma',
      size: '8',
      quantity: 1,
      unitPrice: 79.99,
      imageUrl: 'https://example.com/shoe3-1.jpg',
    ),
    OrderItem(
      shoeId: 'shoe-1',
      shoeName: 'Classic Running Shoes',
      brand: 'Nike',
      size: '10',
      quantity: 1,
      unitPrice: 99.99,
      imageUrl: 'https://example.com/shoe1-1.jpg',
    ),
    OrderItem(
      shoeId: 'shoe-4',
      shoeName: 'Trail Running Shoes',
      brand: 'Salomon',
      size: '9',
      quantity: 1,
      unitPrice: 149.99,
      imageUrl: 'https://example.com/shoe4-1.jpg',
    ),
  ];

  // Fake order instances
  static final List<Order> _orders = [
    Order(
      id: 'order-1',
      userId: 'user-1',
      items: [_orderItems[0], _orderItems[1]],
      totalPrice: 329.97,
      createdAt: DateTime(2024, 1, 15),
      status: OrderStatus.delivered,
      shippingAddress: '123 Main St, City, State 12345',
      paymentMethod: 'Credit Card',
    ),
    Order(
      id: 'order-2',
      userId: 'user-1',
      items: [_orderItems[2]],
      totalPrice: 79.99,
      createdAt: DateTime(2024, 2, 1),
      status: OrderStatus.shipped,
      shippingAddress: '123 Main St, City, State 12345',
      paymentMethod: 'PayPal',
    ),
    Order(
      id: 'order-3',
      userId: 'admin-1',
      items: [_orderItems[3]],
      totalPrice: 99.99,
      createdAt: DateTime(2024, 1, 20),
      status: OrderStatus.processing,
      shippingAddress: '456 Admin Ave, City, State 67890',
      paymentMethod: 'Credit Card',
    ),
    Order(
      id: 'order-4',
      userId: 'admin-1',
      items: [_orderItems[4]],
      totalPrice: 149.99,
      createdAt: DateTime(2024, 2, 5),
      status: OrderStatus.pending,
      shippingAddress: '456 Admin Ave, City, State 67890',
      paymentMethod: 'Debit Card',
    ),
    Order(
      id: 'order-5',
      userId: 'admin-1',
      items: [_orderItems[0], _orderItems[2]],
      totalPrice: 279.97,
      createdAt: DateTime(2024, 2, 6),
      status: OrderStatus.cancelled,
      shippingAddress: '456 Admin Ave, City, State 67890',
      paymentMethod: 'Credit Card',
    ),
  ];

  /// Get order item by ID (using index as ID for mock purposes)
  Future<OrderItem?> getItemById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = int.parse(id.replaceAll('order-item-', ''));
      if (index >= 0 && index < _orderItems.length) {
        return _orderItems[index];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get order items by list of IDs
  Future<List<OrderItem>> getItemsByIds(List<String> ids) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final items = <OrderItem>[];
    for (final id in ids) {
      final item = await getItemById(id);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  /// Get orders by list of IDs
  Future<List<Order>> getOrdersByIds(List<String> ids) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _orders.where((order) => ids.contains(order.id)).toList();
  }

  /// Get order by ID
  Future<Order?> getOrderById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}
