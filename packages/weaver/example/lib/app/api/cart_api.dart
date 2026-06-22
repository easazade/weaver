import '../models/cart.dart';
import '../models/cart_item.dart';
import 'shoe_api.dart';

class CartApi {
  final ShoeApi _shoeApi = ShoeApi();

  // Fake cart instances
  static final Cart _userCart = Cart(
    userId: 'user-1',
    items: [],
  );

  static final Cart _adminCart = Cart(
    userId: 'admin-1',
    items: [],
  );

  // Fake cart item instances (these would typically be stored in carts)
  static final List<CartItem> _cartItems = [
    CartItem(
      shoeId: 'shoe-1',
      size: '9',
      quantity: 2,
    ),
    CartItem(
      shoeId: 'shoe-2',
      size: '10',
      quantity: 1,
    ),
    CartItem(
      shoeId: 'shoe-3',
      size: '8',
      quantity: 3,
    ),
  ];

  /// Get cart item by ID (using index as ID for mock purposes)
  Future<CartItem?> getItemById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = int.parse(id.replaceAll('cart-item-', ''));
      if (index >= 0 && index < _cartItems.length) {
        final item = _cartItems[index];
        // Populate shoe data if available
        final shoe = await _shoeApi.getItemById(item.shoeId);
        return CartItem(
          shoeId: item.shoeId,
          size: item.size,
          quantity: item.quantity,
          shoe: shoe,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cart items by list of IDs
  Future<List<CartItem>> getItemsByIds(List<String> ids) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final items = <CartItem>[];
    for (final id in ids) {
      final item = await getItemById(id);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  /// Get cart by user ID
  Future<Cart?> getCartByUserId(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (userId == 'user-1') {
      return _userCart;
    } else if (userId == 'admin-1') {
      return _adminCart;
    }
    return null;
  }
}
