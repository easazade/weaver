// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order.dart';

class OrderStatusMapper extends EnumMapper<OrderStatus> {
  OrderStatusMapper._();

  static OrderStatusMapper? _instance;
  static OrderStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusMapper._());
    }
    return _instance!;
  }

  static OrderStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return OrderStatus.pending;
      case r'processing':
        return OrderStatus.processing;
      case r'shipped':
        return OrderStatus.shipped;
      case r'delivered':
        return OrderStatus.delivered;
      case r'cancelled':
        return OrderStatus.cancelled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderStatus self) {
    switch (self) {
      case OrderStatus.pending:
        return r'pending';
      case OrderStatus.processing:
        return r'processing';
      case OrderStatus.shipped:
        return r'shipped';
      case OrderStatus.delivered:
        return r'delivered';
      case OrderStatus.cancelled:
        return r'cancelled';
    }
  }
}

extension OrderStatusMapperExtension on OrderStatus {
  String toValue() {
    OrderStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderStatus>(this) as String;
  }
}

class OrderMapper extends ClassMapperBase<Order> {
  OrderMapper._();

  static OrderMapper? _instance;
  static OrderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderMapper._());
      OrderItemMapper.ensureInitialized();
      OrderStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Order';

  static String _$id(Order v) => v.id;
  static const Field<Order, String> _f$id = Field('id', _$id);
  static String _$userId(Order v) => v.userId;
  static const Field<Order, String> _f$userId = Field('userId', _$userId);
  static List<OrderItem> _$items(Order v) => v.items;
  static const Field<Order, List<OrderItem>> _f$items = Field('items', _$items);
  static double _$totalPrice(Order v) => v.totalPrice;
  static const Field<Order, double> _f$totalPrice = Field(
    'totalPrice',
    _$totalPrice,
  );
  static DateTime _$createdAt(Order v) => v.createdAt;
  static const Field<Order, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static OrderStatus _$status(Order v) => v.status;
  static const Field<Order, OrderStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: OrderStatus.pending,
  );
  static String? _$shippingAddress(Order v) => v.shippingAddress;
  static const Field<Order, String> _f$shippingAddress = Field(
    'shippingAddress',
    _$shippingAddress,
    opt: true,
  );
  static String? _$paymentMethod(Order v) => v.paymentMethod;
  static const Field<Order, String> _f$paymentMethod = Field(
    'paymentMethod',
    _$paymentMethod,
    opt: true,
  );

  @override
  final MappableFields<Order> fields = const {
    #id: _f$id,
    #userId: _f$userId,
    #items: _f$items,
    #totalPrice: _f$totalPrice,
    #createdAt: _f$createdAt,
    #status: _f$status,
    #shippingAddress: _f$shippingAddress,
    #paymentMethod: _f$paymentMethod,
  };

  static Order _instantiate(DecodingData data) {
    return Order(
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      items: data.dec(_f$items),
      totalPrice: data.dec(_f$totalPrice),
      createdAt: data.dec(_f$createdAt),
      status: data.dec(_f$status),
      shippingAddress: data.dec(_f$shippingAddress),
      paymentMethod: data.dec(_f$paymentMethod),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Order fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Order>(map);
  }

  static Order fromJson(String json) {
    return ensureInitialized().decodeJson<Order>(json);
  }
}

mixin OrderMappable {
  String toJson() {
    return OrderMapper.ensureInitialized().encodeJson<Order>(this as Order);
  }

  Map<String, dynamic> toMap() {
    return OrderMapper.ensureInitialized().encodeMap<Order>(this as Order);
  }

  OrderCopyWith<Order, Order, Order> get copyWith =>
      _OrderCopyWithImpl<Order, Order>(this as Order, $identity, $identity);
  @override
  String toString() {
    return OrderMapper.ensureInitialized().stringifyValue(this as Order);
  }

  @override
  bool operator ==(Object other) {
    return OrderMapper.ensureInitialized().equalsValue(this as Order, other);
  }

  @override
  int get hashCode {
    return OrderMapper.ensureInitialized().hashValue(this as Order);
  }
}

extension OrderValueCopy<$R, $Out> on ObjectCopyWith<$R, Order, $Out> {
  OrderCopyWith<$R, Order, $Out> get $asOrder =>
      $base.as((v, t, t2) => _OrderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderCopyWith<$R, $In extends Order, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, OrderItem, OrderItemCopyWith<$R, OrderItem, OrderItem>>
  get items;
  $R call({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalPrice,
    DateTime? createdAt,
    OrderStatus? status,
    String? shippingAddress,
    String? paymentMethod,
  });
  OrderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Order, $Out>
    implements OrderCopyWith<$R, Order, $Out> {
  _OrderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Order> $mapper = OrderMapper.ensureInitialized();
  @override
  ListCopyWith<$R, OrderItem, OrderItemCopyWith<$R, OrderItem, OrderItem>>
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalPrice,
    DateTime? createdAt,
    OrderStatus? status,
    Object? shippingAddress = $none,
    Object? paymentMethod = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (userId != null) #userId: userId,
      if (items != null) #items: items,
      if (totalPrice != null) #totalPrice: totalPrice,
      if (createdAt != null) #createdAt: createdAt,
      if (status != null) #status: status,
      if (shippingAddress != $none) #shippingAddress: shippingAddress,
      if (paymentMethod != $none) #paymentMethod: paymentMethod,
    }),
  );
  @override
  Order $make(CopyWithData data) => Order(
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    items: data.get(#items, or: $value.items),
    totalPrice: data.get(#totalPrice, or: $value.totalPrice),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    status: data.get(#status, or: $value.status),
    shippingAddress: data.get(#shippingAddress, or: $value.shippingAddress),
    paymentMethod: data.get(#paymentMethod, or: $value.paymentMethod),
  );

  @override
  OrderCopyWith<$R2, Order, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

