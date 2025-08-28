import 'package:dart_mappable/dart_mappable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ordermate/menu/models/menu.dart';

part 'menu_export.mapper.dart';

@MappableClass()
class MenuExport with MenuExportMappable {
  final int version;
  final DateTime timestamp;
  final Menu menu;

  MenuExport(this.version, this.timestamp, this.menu);

  factory MenuExport.fromJson(Map<String, dynamic> json) =>
      MenuExportMapper.fromJson(json);
}
