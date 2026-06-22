// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_item.dart';

class OrderItemMapper extends ClassMapperBase<OrderItem> {
  OrderItemMapper._();

  static OrderItemMapper? _instance;
  static OrderItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrderItem';

  static String _$shoeId(OrderItem v) => v.shoeId;
  static const Field<OrderItem, String> _f$shoeId = Field('shoeId', _$shoeId);
  static String _$shoeName(OrderItem v) => v.shoeName;
  static const Field<OrderItem, String> _f$shoeName = Field(
    'shoeName',
    _$shoeName,
  );
  static String _$brand(OrderItem v) => v.brand;
  static const Field<OrderItem, String> _f$brand = Field('brand', _$brand);
  static String _$size(OrderItem v) => v.size;
  static const Field<OrderItem, String> _f$size = Field('size', _$size);
  static int _$quantity(OrderItem v) => v.quantity;
  static const Field<OrderItem, int> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static double _$unitPrice(OrderItem v) => v.unitPrice;
  static const Field<OrderItem, double> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static String? _$imageUrl(OrderItem v) => v.imageUrl;
  static const Field<OrderItem, String> _f$imageUrl = Field(
    'imageUrl',
    _$imageUrl,
    opt: true,
  );

  @override
  final MappableFields<OrderItem> fields = const {
    #shoeId: _f$shoeId,
    #shoeName: _f$shoeName,
    #brand: _f$brand,
    #size: _f$size,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #imageUrl: _f$imageUrl,
  };

  static OrderItem _instantiate(DecodingData data) {
    return OrderItem(
      shoeId: data.dec(_f$shoeId),
      shoeName: data.dec(_f$shoeName),
      brand: data.dec(_f$brand),
      size: data.dec(_f$size),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      imageUrl: data.dec(_f$imageUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderItem>(map);
  }

  static OrderItem fromJson(String json) {
    return ensureInitialized().decodeJson<OrderItem>(json);
  }
}

mixin OrderItemMappable {
  String toJson() {
    return OrderItemMapper.ensureInitialized().encodeJson<OrderItem>(
      this as OrderItem,
    );
  }

  Map<String, dynamic> toMap() {
    return OrderItemMapper.ensureInitialized().encodeMap<OrderItem>(
      this as OrderItem,
    );
  }

  OrderItemCopyWith<OrderItem, OrderItem, OrderItem> get copyWith =>
      _OrderItemCopyWithImpl<OrderItem, OrderItem>(
        this as OrderItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderItemMapper.ensureInitialized().stringifyValue(
      this as OrderItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderItemMapper.ensureInitialized().equalsValue(
      this as OrderItem,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderItemMapper.ensureInitialized().hashValue(this as OrderItem);
  }
}

extension OrderItemValueCopy<$R, $Out> on ObjectCopyWith<$R, OrderItem, $Out> {
  OrderItemCopyWith<$R, OrderItem, $Out> get $asOrderItem =>
      $base.as((v, t, t2) => _OrderItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderItemCopyWith<$R, $In extends OrderItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? shoeId,
    String? shoeName,
    String? brand,
    String? size,
    int? quantity,
    double? unitPrice,
    String? imageUrl,
  });
  OrderItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderItem, $Out>
    implements OrderItemCopyWith<$R, OrderItem, $Out> {
  _OrderItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderItem> $mapper =
      OrderItemMapper.ensureInitialized();
  @override
  $R call({
    String? shoeId,
    String? shoeName,
    String? brand,
    String? size,
    int? quantity,
    double? unitPrice,
    Object? imageUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (shoeId != null) #shoeId: shoeId,
      if (shoeName != null) #shoeName: shoeName,
      if (brand != null) #brand: brand,
      if (size != null) #size: size,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (imageUrl != $none) #imageUrl: imageUrl,
    }),
  );
  @override
  OrderItem $make(CopyWithData data) => OrderItem(
    shoeId: data.get(#shoeId, or: $value.shoeId),
    shoeName: data.get(#shoeName, or: $value.shoeName),
    brand: data.get(#brand, or: $value.brand),
    size: data.get(#size, or: $value.size),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    imageUrl: data.get(#imageUrl, or: $value.imageUrl),
  );

  @override
  OrderItemCopyWith<$R2, OrderItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

