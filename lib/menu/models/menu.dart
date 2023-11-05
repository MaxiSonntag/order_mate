import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/utils/hive_types.dart';

part 'menu.g.dart';

@HiveType(typeId: HiveTypes.menu)
@JsonSerializable(explicitToJson: true)
class Menu extends Equatable {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Product> products;

  @HiveField(3)
  final DateTime updatedAt;

  Menu({
    required this.uuid,
    required this.name,
    required this.products,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        uuid,
        name,
        products,
        updatedAt,
      ];

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
