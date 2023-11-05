import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ordermate/menu/models/product.dart';

part 'product_order.g.dart';

@JsonSerializable()
@CopyWith()
class ProductOrder extends Equatable {
  final Product product;
  final int amount;

  const ProductOrder(this.product, this.amount);

  factory ProductOrder.fromJson(Map<String, dynamic> json) => _$ProductOrderFromJson(json);

  Map<String, dynamic> toJson() => _$ProductOrderToJson(this);

  @override
  List<Object?> get props => [product, amount];
}