// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_order.dart';

class ProductOrderMapper extends ClassMapperBase<ProductOrder> {
  ProductOrderMapper._();

  static ProductOrderMapper? _instance;
  static ProductOrderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductOrderMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProductOrder';

  static Product _$product(ProductOrder v) => v.product;
  static const Field<ProductOrder, Product> _f$product = Field(
    'product',
    _$product,
  );
  static int _$amount(ProductOrder v) => v.amount;
  static const Field<ProductOrder, int> _f$amount = Field('amount', _$amount);

  @override
  final MappableFields<ProductOrder> fields = const {
    #product: _f$product,
    #amount: _f$amount,
  };

  static ProductOrder _instantiate(DecodingData data) {
    return ProductOrder(data.dec(_f$product), data.dec(_f$amount));
  }

  @override
  final Function instantiate = _instantiate;

  static ProductOrder fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductOrder>(map);
  }

  static ProductOrder fromJsonString(String json) {
    return ensureInitialized().decodeJson<ProductOrder>(json);
  }
}

mixin ProductOrderMappable {
  String toJsonString() {
    return ProductOrderMapper.ensureInitialized().encodeJson<ProductOrder>(
      this as ProductOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return ProductOrderMapper.ensureInitialized().encodeMap<ProductOrder>(
      this as ProductOrder,
    );
  }

  ProductOrderCopyWith<ProductOrder, ProductOrder, ProductOrder> get copyWith =>
      _ProductOrderCopyWithImpl<ProductOrder, ProductOrder>(
        this as ProductOrder,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductOrderMapper.ensureInitialized().stringifyValue(
      this as ProductOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductOrderMapper.ensureInitialized().equalsValue(
      this as ProductOrder,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductOrderMapper.ensureInitialized().hashValue(
      this as ProductOrder,
    );
  }
}

extension ProductOrderValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductOrder, $Out> {
  ProductOrderCopyWith<$R, ProductOrder, $Out> get $asProductOrder =>
      $base.as((v, t, t2) => _ProductOrderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductOrderCopyWith<$R, $In extends ProductOrder, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product> get product;
  $R call({Product? product, int? amount});
  ProductOrderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductOrderCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductOrder, $Out>
    implements ProductOrderCopyWith<$R, ProductOrder, $Out> {
  _ProductOrderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductOrder> $mapper =
      ProductOrderMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product> get product =>
      $value.product.copyWith.$chain((v) => call(product: v));
  @override
  $R call({Product? product, int? amount}) => $apply(
    FieldCopyWithData({
      if (product != null) #product: product,
      if (amount != null) #amount: amount,
    }),
  );
  @override
  ProductOrder $make(CopyWithData data) => ProductOrder(
    data.get(#product, or: $value.product),
    data.get(#amount, or: $value.amount),
  );

  @override
  ProductOrderCopyWith<$R2, ProductOrder, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductOrderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

