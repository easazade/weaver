// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'shoe.dart';

class ShoeMapper extends ClassMapperBase<Shoe> {
  ShoeMapper._();

  static ShoeMapper? _instance;
  static ShoeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ShoeMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Shoe';

  static String _$id(Shoe v) => v.id;
  static const Field<Shoe, String> _f$id = Field('id', _$id);
  static String _$name(Shoe v) => v.name;
  static const Field<Shoe, String> _f$name = Field('name', _$name);
  static String _$brand(Shoe v) => v.brand;
  static const Field<Shoe, String> _f$brand = Field('brand', _$brand);
  static String _$description(Shoe v) => v.description;
  static const Field<Shoe, String> _f$description = Field(
    'description',
    _$description,
  );
  static double _$price(Shoe v) => v.price;
  static const Field<Shoe, double> _f$price = Field('price', _$price);
  static List<String> _$imageUrls(Shoe v) => v.imageUrls;
  static const Field<Shoe, List<String>> _f$imageUrls = Field(
    'imageUrls',
    _$imageUrls,
    opt: true,
    def: const [],
  );
  static List<String> _$sizes(Shoe v) => v.sizes;
  static const Field<Shoe, List<String>> _f$sizes = Field(
    'sizes',
    _$sizes,
    opt: true,
    def: const [],
  );
  static Map<String, int> _$stockBySize(Shoe v) => v.stockBySize;
  static const Field<Shoe, Map<String, int>> _f$stockBySize = Field(
    'stockBySize',
    _$stockBySize,
    opt: true,
    def: const {},
  );
  static String? _$category(Shoe v) => v.category;
  static const Field<Shoe, String> _f$category = Field(
    'category',
    _$category,
    opt: true,
  );
  static bool _$isInStock(Shoe v) => v.isInStock;
  static const Field<Shoe, bool> _f$isInStock = Field(
    'isInStock',
    _$isInStock,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Shoe> fields = const {
    #id: _f$id,
    #name: _f$name,
    #brand: _f$brand,
    #description: _f$description,
    #price: _f$price,
    #imageUrls: _f$imageUrls,
    #sizes: _f$sizes,
    #stockBySize: _f$stockBySize,
    #category: _f$category,
    #isInStock: _f$isInStock,
  };

  static Shoe _instantiate(DecodingData data) {
    return Shoe(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      brand: data.dec(_f$brand),
      description: data.dec(_f$description),
      price: data.dec(_f$price),
      imageUrls: data.dec(_f$imageUrls),
      sizes: data.dec(_f$sizes),
      stockBySize: data.dec(_f$stockBySize),
      category: data.dec(_f$category),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Shoe fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Shoe>(map);
  }

  static Shoe fromJson(String json) {
    return ensureInitialized().decodeJson<Shoe>(json);
  }
}

mixin ShoeMappable {
  String toJson() {
    return ShoeMapper.ensureInitialized().encodeJson<Shoe>(this as Shoe);
  }

  Map<String, dynamic> toMap() {
    return ShoeMapper.ensureInitialized().encodeMap<Shoe>(this as Shoe);
  }

  ShoeCopyWith<Shoe, Shoe, Shoe> get copyWith =>
      _ShoeCopyWithImpl<Shoe, Shoe>(this as Shoe, $identity, $identity);
  @override
  String toString() {
    return ShoeMapper.ensureInitialized().stringifyValue(this as Shoe);
  }

  @override
  bool operator ==(Object other) {
    return ShoeMapper.ensureInitialized().equalsValue(this as Shoe, other);
  }

  @override
  int get hashCode {
    return ShoeMapper.ensureInitialized().hashValue(this as Shoe);
  }
}

extension ShoeValueCopy<$R, $Out> on ObjectCopyWith<$R, Shoe, $Out> {
  ShoeCopyWith<$R, Shoe, $Out> get $asShoe =>
      $base.as((v, t, t2) => _ShoeCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ShoeCopyWith<$R, $In extends Shoe, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get imageUrls;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get sizes;
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>> get stockBySize;
  $R call({
    String? id,
    String? name,
    String? brand,
    String? description,
    double? price,
    List<String>? imageUrls,
    List<String>? sizes,
    Map<String, int>? stockBySize,
    String? category,
  });
  ShoeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ShoeCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Shoe, $Out>
    implements ShoeCopyWith<$R, Shoe, $Out> {
  _ShoeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Shoe> $mapper = ShoeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get imageUrls =>
      ListCopyWith(
        $value.imageUrls,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(imageUrls: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get sizes =>
      ListCopyWith(
        $value.sizes,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(sizes: v),
      );
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>> get stockBySize =>
      MapCopyWith(
        $value.stockBySize,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(stockBySize: v),
      );
  @override
  $R call({
    String? id,
    String? name,
    String? brand,
    String? description,
    double? price,
    List<String>? imageUrls,
    List<String>? sizes,
    Map<String, int>? stockBySize,
    Object? category = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (brand != null) #brand: brand,
      if (description != null) #description: description,
      if (price != null) #price: price,
      if (imageUrls != null) #imageUrls: imageUrls,
      if (sizes != null) #sizes: sizes,
      if (stockBySize != null) #stockBySize: stockBySize,
      if (category != $none) #category: category,
    }),
  );
  @override
  Shoe $make(CopyWithData data) => Shoe(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    brand: data.get(#brand, or: $value.brand),
    description: data.get(#description, or: $value.description),
    price: data.get(#price, or: $value.price),
    imageUrls: data.get(#imageUrls, or: $value.imageUrls),
    sizes: data.get(#sizes, or: $value.sizes),
    stockBySize: data.get(#stockBySize, or: $value.stockBySize),
    category: data.get(#category, or: $value.category),
  );

  @override
  ShoeCopyWith<$R2, Shoe, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ShoeCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

