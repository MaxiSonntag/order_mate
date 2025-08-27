// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product.dart';

class ProductMapper extends ClassMapperBase<Product> {
  ProductMapper._();

  static ProductMapper? _instance;
  static ProductMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Product';

  static String _$name(Product v) => v.name;
  static const Field<Product, String> _f$name = Field('name', _$name);
  static String _$unit(Product v) => v.unit;
  static const Field<Product, String> _f$unit = Field('unit', _$unit);
  static num _$price(Product v) => v.price;
  static const Field<Product, num> _f$price = Field('price', _$price);
  static int _$sortingKey(Product v) => v.sortingKey;
  static const Field<Product, int> _f$sortingKey = Field(
    'sortingKey',
    _$sortingKey,
  );
  static String _$hexColor(Product v) => v.hexColor;
  static const Field<Product, String> _f$hexColor = Field(
    'hexColor',
    _$hexColor,
  );
  static Color _$color(Product v) => v.color;
  static const Field<Product, Color> _f$color = Field(
    'color',
    _$color,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<Product> fields = const {
    #name: _f$name,
    #unit: _f$unit,
    #price: _f$price,
    #sortingKey: _f$sortingKey,
    #hexColor: _f$hexColor,
    #color: _f$color,
  };

  static Product _instantiate(DecodingData data) {
    return Product(
      name: data.dec(_f$name),
      unit: data.dec(_f$unit),
      price: data.dec(_f$price),
      sortingKey: data.dec(_f$sortingKey),
      hexColor: data.dec(_f$hexColor),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Product fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Product>(map);
  }

  static Product fromJsonString(String json) {
    return ensureInitialized().decodeJson<Product>(json);
  }
}

mixin ProductMappable {
  String toJsonString() {
    return ProductMapper.ensureInitialized().encodeJson<Product>(
      this as Product,
    );
  }

  Map<String, dynamic> toJson() {
    return ProductMapper.ensureInitialized().encodeMap<Product>(
      this as Product,
    );
  }

  ProductCopyWith<Product, Product, Product> get copyWith =>
      _ProductCopyWithImpl<Product, Product>(
        this as Product,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductMapper.ensureInitialized().stringifyValue(this as Product);
  }

  @override
  bool operator ==(Object other) {
    return ProductMapper.ensureInitialized().equalsValue(
      this as Product,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductMapper.ensureInitialized().hashValue(this as Product);
  }
}

extension ProductValueCopy<$R, $Out> on ObjectCopyWith<$R, Product, $Out> {
  ProductCopyWith<$R, Product, $Out> get $asProduct =>
      $base.as((v, t, t2) => _ProductCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductCopyWith<$R, $In extends Product, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    String? unit,
    num? price,
    int? sortingKey,
    String? hexColor,
  });
  ProductCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Product, $Out>
    implements ProductCopyWith<$R, Product, $Out> {
  _ProductCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Product> $mapper =
      ProductMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    String? unit,
    num? price,
    int? sortingKey,
    String? hexColor,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (unit != null) #unit: unit,
      if (price != null) #price: price,
      if (sortingKey != null) #sortingKey: sortingKey,
      if (hexColor != null) #hexColor: hexColor,
    }),
  );
  @override
  Product $make(CopyWithData data) => Product(
    name: data.get(#name, or: $value.name),
    unit: data.get(#unit, or: $value.unit),
    price: data.get(#price, or: $value.price),
    sortingKey: data.get(#sortingKey, or: $value.sortingKey),
    hexColor: data.get(#hexColor, or: $value.hexColor),
  );

  @override
  ProductCopyWith<$R2, Product, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProductCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

