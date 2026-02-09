// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_item.dart';

class CartItemMapper extends ClassMapperBase<CartItem> {
  CartItemMapper._();

  static CartItemMapper? _instance;
  static CartItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartItemMapper._());
      ShoeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartItem';

  static String _$shoeId(CartItem v) => v.shoeId;
  static const Field<CartItem, String> _f$shoeId = Field('shoeId', _$shoeId);
  static String _$size(CartItem v) => v.size;
  static const Field<CartItem, String> _f$size = Field('size', _$size);
  static int _$quantity(CartItem v) => v.quantity;
  static const Field<CartItem, int> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 1,
  );
  static Shoe? _$shoe(CartItem v) => v.shoe;
  static const Field<CartItem, Shoe> _f$shoe = Field('shoe', _$shoe, opt: true);

  @override
  final MappableFields<CartItem> fields = const {
    #shoeId: _f$shoeId,
    #size: _f$size,
    #quantity: _f$quantity,
    #shoe: _f$shoe,
  };

  static CartItem _instantiate(DecodingData data) {
    return CartItem(
      shoeId: data.dec(_f$shoeId),
      size: data.dec(_f$size),
      quantity: data.dec(_f$quantity),
      shoe: data.dec(_f$shoe),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartItem>(map);
  }

  static CartItem fromJson(String json) {
    return ensureInitialized().decodeJson<CartItem>(json);
  }
}

mixin CartItemMappable {
  String toJson() {
    return CartItemMapper.ensureInitialized().encodeJson<CartItem>(
      this as CartItem,
    );
  }

  Map<String, dynamic> toMap() {
    return CartItemMapper.ensureInitialized().encodeMap<CartItem>(
      this as CartItem,
    );
  }

  CartItemCopyWith<CartItem, CartItem, CartItem> get copyWith =>
      _CartItemCopyWithImpl<CartItem, CartItem>(
        this as CartItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartItemMapper.ensureInitialized().stringifyValue(this as CartItem);
  }

  @override
  bool operator ==(Object other) {
    return CartItemMapper.ensureInitialized().equalsValue(
      this as CartItem,
      other,
    );
  }

  @override
  int get hashCode {
    return CartItemMapper.ensureInitialized().hashValue(this as CartItem);
  }
}

extension CartItemValueCopy<$R, $Out> on ObjectCopyWith<$R, CartItem, $Out> {
  CartItemCopyWith<$R, CartItem, $Out> get $asCartItem =>
      $base.as((v, t, t2) => _CartItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartItemCopyWith<$R, $In extends CartItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ShoeCopyWith<$R, Shoe, Shoe>? get shoe;
  $R call({String? shoeId, String? size, int? quantity, Shoe? shoe});
  CartItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartItem, $Out>
    implements CartItemCopyWith<$R, CartItem, $Out> {
  _CartItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartItem> $mapper =
      CartItemMapper.ensureInitialized();
  @override
  ShoeCopyWith<$R, Shoe, Shoe>? get shoe =>
      $value.shoe?.copyWith.$chain((v) => call(shoe: v));
  @override
  $R call({
    String? shoeId,
    String? size,
    int? quantity,
    Object? shoe = $none,
  }) => $apply(
    FieldCopyWithData({
      if (shoeId != null) #shoeId: shoeId,
      if (size != null) #size: size,
      if (quantity != null) #quantity: quantity,
      if (shoe != $none) #shoe: shoe,
    }),
  );
  @override
  CartItem $make(CopyWithData data) => CartItem(
    shoeId: data.get(#shoeId, or: $value.shoeId),
    size: data.get(#size, or: $value.size),
    quantity: data.get(#quantity, or: $value.quantity),
    shoe: data.get(#shoe, or: $value.shoe),
  );

  @override
  CartItemCopyWith<$R2, CartItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

