import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ordermate/menu/models/menu.dart';

part 'menu_export.g.dart';

@JsonSerializable()
class MenuExport {
  final int version;
  final DateTime timestamp;
  final Menu menu;

  MenuExport(this.version, this.timestamp, this.menu);

  factory MenuExport.fromJson(Map<String, dynamic> json) =>
      _$MenuExportFromJson(json);

  Map<String, dynamic> toJson() => _$MenuExportToJson(this);
}
