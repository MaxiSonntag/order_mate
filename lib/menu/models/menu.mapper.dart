// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu.dart';

class MenuMapper extends ClassMapperBase<Menu> {
  MenuMapper._();

  static MenuMapper? _instance;
  static MenuMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Menu';

  static String _$uuid(Menu v) => v.uuid;
  static const Field<Menu, String> _f$uuid = Field('uuid', _$uuid);
  static String _$name(Menu v) => v.name;
  static const Field<Menu, String> _f$name = Field('name', _$name);
  static List<Product> _$products(Menu v) => v.products;
  static const Field<Menu, List<Product>> _f$products = Field(
    'products',
    _$products,
  );
  static DateTime _$updatedAt(Menu v) => v.updatedAt;
  static const Field<Menu, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
    opt: true,
  );

  @override
  final MappableFields<Menu> fields = const {
    #uuid: _f$uuid,
    #name: _f$name,
    #products: _f$products,
    #updatedAt: _f$updatedAt,
  };

  static Menu _instantiate(DecodingData data) {
    return Menu(
      uuid: data.dec(_f$uuid),
      name: data.dec(_f$name),
      products: data.dec(_f$products),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Menu fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Menu>(map);
  }

  static Menu fromJsonString(String json) {
    return ensureInitialized().decodeJson<Menu>(json);
  }
}

mixin MenuMappable {
  String toJsonString() {
    return MenuMapper.ensureInitialized().encodeJson<Menu>(this as Menu);
  }

  Map<String, dynamic> toJson() {
    return MenuMapper.ensureInitialized().encodeMap<Menu>(this as Menu);
  }

  MenuCopyWith<Menu, Menu, Menu> get copyWith =>
      _MenuCopyWithImpl<Menu, Menu>(this as Menu, $identity, $identity);
  @override
  String toString() {
    return MenuMapper.ensureInitialized().stringifyValue(this as Menu);
  }

  @override
  bool operator ==(Object other) {
    return MenuMapper.ensureInitialized().equalsValue(this as Menu, other);
  }

  @override
  int get hashCode {
    return MenuMapper.ensureInitialized().hashValue(this as Menu);
  }
}

extension MenuValueCopy<$R, $Out> on ObjectCopyWith<$R, Menu, $Out> {
  MenuCopyWith<$R, Menu, $Out> get $asMenu =>
      $base.as((v, t, t2) => _MenuCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuCopyWith<$R, $In extends Menu, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Product, ProductCopyWith<$R, Product, Product>> get products;
  $R call({
    String? uuid,
    String? name,
    List<Product>? products,
    DateTime? updatedAt,
  });
  MenuCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Menu, $Out>
    implements MenuCopyWith<$R, Menu, $Out> {
  _MenuCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Menu> $mapper = MenuMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Product, ProductCopyWith<$R, Product, Product>>
  get products => ListCopyWith(
    $value.products,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(products: v),
  );
  @override
  $R call({
    String? uuid,
    String? name,
    List<Product>? products,
    Object? updatedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (uuid != null) #uuid: uuid,
      if (name != null) #name: name,
      if (products != null) #products: products,
      if (updatedAt != $none) #updatedAt: updatedAt,
    }),
  );
  @override
  Menu $make(CopyWithData data) => Menu(
    uuid: data.get(#uuid, or: $value.uuid),
    name: data.get(#name, or: $value.name),
    products: data.get(#products, or: $value.products),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  MenuCopyWith<$R2, Menu, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MenuCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

