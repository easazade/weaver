import '../models/order.dart';
import '../models/shoes.dart';
import '../models/user.dart';
import 'shoes_api.dart';

class UserApi {
  final ShoesApi _shoesApi;

  UserApi(this._shoesApi);

  // Mock current user
  User? _currentUser;

  // Mock orders data
  final Map<String, List<Order>> _userOrders = {};

  Future<User?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock login - accept any credentials for testing
    _currentUser = User(
      id: '1',
      username: username,
      email: '$username@example.com',
      isAdmin: username == 'admin', // Admin user for testing
    );

    return _currentUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  Future<Order> purchaseShoes(String userId, List<String> shoesIds) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Get actual shoes objects
    final shoesList = <Shoes>[];
    double total = 0.0;

    for (final id in shoesIds) {
      final shoe = await _shoesApi.getShoesById(id);
      if (shoe != null) {
        shoesList.add(shoe);
        total += shoe.price;
      }
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: shoesList,
      total: total,
      date: DateTime.now(),
    );

    _userOrders.putIfAbsent(userId, () => []).add(order);
    return order;
  }

  Future<List<Order>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_userOrders[userId] ?? []);
  }
}
