import 'package:dart_mappable/dart_mappable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ordermate/menu/models/product.dart';

part 'product_order.mapper.dart';

@MappableClass()
class ProductOrder extends HiveObject with ProductOrderMappable {
  final Product product;
  final int amount;

  ProductOrder(this.product, this.amount);

  factory ProductOrder.fromJson(Map<String, dynamic> json) =>
      ProductOrderMapper.fromJson(json);
}
