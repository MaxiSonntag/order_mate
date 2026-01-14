import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/painting.dart';
import 'package:hive_ce/hive.dart';
import 'package:ordermate/utils/extensions.dart';
import 'package:ordermate/utils/hive_types.dart';

part 'product.mapper.dart';

@MappableClass()
class Product with ProductMappable {
  const Product({
    required this.name,
    required this.unit,
    required this.price,
    required this.sortingKey,
    required this.hexColor,
    this.isSectionEnd = false,
  });

  final String name;
  final String unit;
  final num price;
  final int sortingKey;
  final String hexColor;
  final bool isSectionEnd;

  Color get color => ColorX.fromHex(hexColor);

  factory Product.fromJson(Map<String, dynamic> json) =>
      ProductMapper.fromJson(json);
}
