import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ordermate/order/product_order.dart';

part 'customer_order.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CustomerOrder extends Equatable {
  final String name;
  final List<ProductOrder> order;

  const CustomerOrder({
    required this.name,
    required this.order,
  });

  factory CustomerOrder.empty(String name) {
    return CustomerOrder(name: name, order: const []);
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) =>
      _$CustomerOrderFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerOrderToJson(this);

  @override
  List<Object?> get props => [name, order];
}

enum CustomerOrderError {
  duplicateOrderName('DUPLICATE_ORDER_NAME');

  final String error;
  const CustomerOrderError(this.error);
}
