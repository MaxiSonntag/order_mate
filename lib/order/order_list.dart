import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/product_order_view.dart';
import 'package:ordermate/utils/constants.dart';

class OrderList extends StatefulWidget {
  const OrderList({
    required this.order,
    required this.emptyHintText,
    this.readOnly = false,
    this.onTap,
    this.useTopGradient = false,
    this.useBottomGradient = false,
    super.key,
  });

  final List<ProductOrder> order;
  final String emptyHintText;
  final bool readOnly;
  final void Function(Product)? onTap;
  final bool useTopGradient;
  final bool useBottomGradient;

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.emptyHintText),
          ),
        ),
      );
    }

    final orderedProducts = widget.order
      ..sort(
        (o1, o2) => o1.product.sortingKey - o2.product.sortingKey,
      );
    return FadingEdgeScrollView.fromScrollView(
      gradientFractionOnStart: widget.useTopGradient ? 0.1 : 0,
      gradientFractionOnEnd: widget.useBottomGradient ? 0.1 : 0,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: EdgeInsets.only(bottom: AppConstants.spacingM),
        itemCount: widget.order.length,
        itemBuilder: (context, index) => ProductOrderTile(
          order: orderedProducts[index],
          readOnly: widget.readOnly,
          onTap: () => widget.onTap?.call(orderedProducts[index].product),
        ),
      ),
    );
  }
}
