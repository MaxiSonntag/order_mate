import 'package:flutter/material.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/product_order_view.dart';

class OrderList extends StatelessWidget {
  const OrderList({
    required this.order,
    required this.emptyHintText,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  final List<ProductOrder> order;
  final String emptyHintText;
  final bool readOnly;
  final void Function(Product)? onTap;

  @override
  Widget build(BuildContext context) {
    if (order.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(emptyHintText),
          ),
        ),
      );
    }

    final orderedProducts = order
      ..sort(
        (o1, o2) => o1.product.sortingKey - o2.product.sortingKey,
      );
    return ListView.builder(
      itemCount: order.length,
      itemBuilder: (context, index) => ProductOrderTile(
        order: orderedProducts[index],
        readOnly: readOnly,
        onTap: () => onTap?.call(orderedProducts[index].product),
      ),
    );
  }
}
