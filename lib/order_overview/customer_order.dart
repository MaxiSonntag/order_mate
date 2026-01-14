import 'package:dart_mappable/dart_mappable.dart';
import 'package:ordermate/order/product_order.dart';

part 'customer_order.mapper.dart';

@MappableClass()
class CustomerOrder with CustomerOrderMappable {
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
      CustomerOrderMapper.fromJson(json);
}

enum CustomerOrderError {
  duplicateOrderName('DUPLICATE_ORDER_NAME');

  final String error;
  const CustomerOrderError(this.error);
}
