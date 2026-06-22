// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart.dart';

class CartMapper extends ClassMapperBase<Cart> {
  CartMapper._();

  static CartMapper? _instance;
  static CartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartMapper._());
      CartItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Cart';

  static String _$userId(Cart v) => v.userId;
  static const Field<Cart, String> _f$userId = Field('userId', _$userId);
  static List<CartItem> _$items(Cart v) => v.items;
  static const Field<Cart, List<CartItem>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<Cart> fields = const {
    #userId: _f$userId,
    #items: _f$items,
  };

  static Cart _instantiate(DecodingData data) {
    return Cart(userId: data.dec(_f$userId), items: data.dec(_f$items));
  }

  @override
  final Function instantiate = _instantiate;

  static Cart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Cart>(map);
  }

  static Cart fromJson(String json) {
    return ensureInitialized().decodeJson<Cart>(json);
  }
}

mixin CartMappable {
  String toJson() {
    return CartMapper.ensureInitialized().encodeJson<Cart>(this as Cart);
  }

  Map<String, dynamic> toMap() {
    return CartMapper.ensureInitialized().encodeMap<Cart>(this as Cart);
  }

  CartCopyWith<Cart, Cart, Cart> get copyWith =>
      _CartCopyWithImpl<Cart, Cart>(this as Cart, $identity, $identity);
  @override
  String toString() {
    return CartMapper.ensureInitialized().stringifyValue(this as Cart);
  }

  @override
  bool operator ==(Object other) {
    return CartMapper.ensureInitialized().equalsValue(this as Cart, other);
  }

  @override
  int get hashCode {
    return CartMapper.ensureInitialized().hashValue(this as Cart);
  }
}

extension CartValueCopy<$R, $Out> on ObjectCopyWith<$R, Cart, $Out> {
  CartCopyWith<$R, Cart, $Out> get $asCart =>
      $base.as((v, t, t2) => _CartCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartCopyWith<$R, $In extends Cart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CartItem, CartItemCopyWith<$R, CartItem, CartItem>>
  get items;
  $R call({String? userId, List<CartItem>? items});
  CartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Cart, $Out>
    implements CartCopyWith<$R, Cart, $Out> {
  _CartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Cart> $mapper = CartMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CartItem, CartItemCopyWith<$R, CartItem, CartItem>>
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({String? userId, List<CartItem>? items}) => $apply(
    FieldCopyWithData({
      if (userId != null) #userId: userId,
      if (items != null) #items: items,
    }),
  );
  @override
  Cart $make(CopyWithData data) => Cart(
    userId: data.get(#userId, or: $value.userId),
    items: data.get(#items, or: $value.items),
  );

  @override
  CartCopyWith<$R2, Cart, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

