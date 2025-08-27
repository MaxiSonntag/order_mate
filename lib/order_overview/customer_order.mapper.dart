// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'customer_order.dart';

class CustomerOrderMapper extends ClassMapperBase<CustomerOrder> {
  CustomerOrderMapper._();

  static CustomerOrderMapper? _instance;
  static CustomerOrderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CustomerOrderMapper._());
      ProductOrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CustomerOrder';

  static String _$name(CustomerOrder v) => v.name;
  static const Field<CustomerOrder, String> _f$name = Field('name', _$name);
  static List<ProductOrder> _$order(CustomerOrder v) => v.order;
  static const Field<CustomerOrder, List<ProductOrder>> _f$order = Field(
    'order',
    _$order,
  );

  @override
  final MappableFields<CustomerOrder> fields = const {
    #name: _f$name,
    #order: _f$order,
  };

  static CustomerOrder _instantiate(DecodingData data) {
    return CustomerOrder(name: data.dec(_f$name), order: data.dec(_f$order));
  }

  @override
  final Function instantiate = _instantiate;

  static CustomerOrder fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CustomerOrder>(map);
  }

  static CustomerOrder fromJsonString(String json) {
    return ensureInitialized().decodeJson<CustomerOrder>(json);
  }
}

mixin CustomerOrderMappable {
  String toJsonString() {
    return CustomerOrderMapper.ensureInitialized().encodeJson<CustomerOrder>(
      this as CustomerOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return CustomerOrderMapper.ensureInitialized().encodeMap<CustomerOrder>(
      this as CustomerOrder,
    );
  }

  CustomerOrderCopyWith<CustomerOrder, CustomerOrder, CustomerOrder>
  get copyWith => _CustomerOrderCopyWithImpl<CustomerOrder, CustomerOrder>(
    this as CustomerOrder,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CustomerOrderMapper.ensureInitialized().stringifyValue(
      this as CustomerOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    return CustomerOrderMapper.ensureInitialized().equalsValue(
      this as CustomerOrder,
      other,
    );
  }

  @override
  int get hashCode {
    return CustomerOrderMapper.ensureInitialized().hashValue(
      this as CustomerOrder,
    );
  }
}

extension CustomerOrderValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CustomerOrder, $Out> {
  CustomerOrderCopyWith<$R, CustomerOrder, $Out> get $asCustomerOrder =>
      $base.as((v, t, t2) => _CustomerOrderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CustomerOrderCopyWith<$R, $In extends CustomerOrder, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ProductOrder,
    ProductOrderCopyWith<$R, ProductOrder, ProductOrder>
  >
  get order;
  $R call({String? name, List<ProductOrder>? order});
  CustomerOrderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CustomerOrderCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CustomerOrder, $Out>
    implements CustomerOrderCopyWith<$R, CustomerOrder, $Out> {
  _CustomerOrderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CustomerOrder> $mapper =
      CustomerOrderMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ProductOrder,
    ProductOrderCopyWith<$R, ProductOrder, ProductOrder>
  >
  get order => ListCopyWith(
    $value.order,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(order: v),
  );
  @override
  $R call({String? name, List<ProductOrder>? order}) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (order != null) #order: order,
    }),
  );
  @override
  CustomerOrder $make(CopyWithData data) => CustomerOrder(
    name: data.get(#name, or: $value.name),
    order: data.get(#order, or: $value.order),
  );

  @override
  CustomerOrderCopyWith<$R2, CustomerOrder, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CustomerOrderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

