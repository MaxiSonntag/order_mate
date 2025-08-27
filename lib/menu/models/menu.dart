import 'package:dart_mappable/dart_mappable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ordermate/menu/models/product.dart';

part 'menu.mapper.dart';

@MappableClass()
class Menu extends HiveObject with MenuMappable {
  Menu({
    required this.uuid,
    required this.name,
    required this.products,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String uuid;
  final String name;
  final List<Product> products;
  final DateTime updatedAt;

  factory Menu.fromJson(Map<String, dynamic> json) => MenuMapper.fromJson(json);
}
