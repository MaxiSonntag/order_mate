// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_export.dart';

class MenuExportMapper extends ClassMapperBase<MenuExport> {
  MenuExportMapper._();

  static MenuExportMapper? _instance;
  static MenuExportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuExportMapper._());
      MenuMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuExport';

  static int _$version(MenuExport v) => v.version;
  static const Field<MenuExport, int> _f$version = Field('version', _$version);
  static DateTime _$timestamp(MenuExport v) => v.timestamp;
  static const Field<MenuExport, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static Menu _$menu(MenuExport v) => v.menu;
  static const Field<MenuExport, Menu> _f$menu = Field('menu', _$menu);

  @override
  final MappableFields<MenuExport> fields = const {
    #version: _f$version,
    #timestamp: _f$timestamp,
    #menu: _f$menu,
  };

  static MenuExport _instantiate(DecodingData data) {
    return MenuExport(
      data.dec(_f$version),
      data.dec(_f$timestamp),
      data.dec(_f$menu),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuExport fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuExport>(map);
  }

  static MenuExport fromJsonString(String json) {
    return ensureInitialized().decodeJson<MenuExport>(json);
  }
}

mixin MenuExportMappable {
  String toJsonString() {
    return MenuExportMapper.ensureInitialized().encodeJson<MenuExport>(
      this as MenuExport,
    );
  }

  Map<String, dynamic> toJson() {
    return MenuExportMapper.ensureInitialized().encodeMap<MenuExport>(
      this as MenuExport,
    );
  }

  MenuExportCopyWith<MenuExport, MenuExport, MenuExport> get copyWith =>
      _MenuExportCopyWithImpl<MenuExport, MenuExport>(
        this as MenuExport,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuExportMapper.ensureInitialized().stringifyValue(
      this as MenuExport,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuExportMapper.ensureInitialized().equalsValue(
      this as MenuExport,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuExportMapper.ensureInitialized().hashValue(this as MenuExport);
  }
}

extension MenuExportValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuExport, $Out> {
  MenuExportCopyWith<$R, MenuExport, $Out> get $asMenuExport =>
      $base.as((v, t, t2) => _MenuExportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuExportCopyWith<$R, $In extends MenuExport, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MenuCopyWith<$R, Menu, Menu> get menu;
  $R call({int? version, DateTime? timestamp, Menu? menu});
  MenuExportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuExportCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuExport, $Out>
    implements MenuExportCopyWith<$R, MenuExport, $Out> {
  _MenuExportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuExport> $mapper =
      MenuExportMapper.ensureInitialized();
  @override
  MenuCopyWith<$R, Menu, Menu> get menu =>
      $value.menu.copyWith.$chain((v) => call(menu: v));
  @override
  $R call({int? version, DateTime? timestamp, Menu? menu}) => $apply(
    FieldCopyWithData({
      if (version != null) #version: version,
      if (timestamp != null) #timestamp: timestamp,
      if (menu != null) #menu: menu,
    }),
  );
  @override
  MenuExport $make(CopyWithData data) => MenuExport(
    data.get(#version, or: $value.version),
    data.get(#timestamp, or: $value.timestamp),
    data.get(#menu, or: $value.menu),
  );

  @override
  MenuExportCopyWith<$R2, MenuExport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuExportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

