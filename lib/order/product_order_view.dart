import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/widgets/text_input_bottom_sheet.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/subtotal_cubit.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/utils/extensions.dart';

class ProductOrderView extends StatelessWidget {
  final String orderName;
  final bool readOnly;

  const ProductOrderView({
    this.orderName = OrderCubit.orderNamePlaceholder,
    this.readOnly = false,
    super.key,
  });

  _onPressed(BuildContext context, bool multipleOrdersAllowed) async {
    final navigator = Navigator.of(context);
    final orderCubit = context.read<OrderCubit>();

    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      final orderName = await showModalBottomSheet<String>(
        context: context,
        builder: (_) => TextInputBottomSheet(
          currentValue: '',
          displayName: context.translate.orderName,
        ),
      );
      if (orderName != null) {
        orderCubit.setOrderName(orderName);
        navigator.pop();
      }
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      orderCubit.removeOrder(orderName);
      navigator.pop();
    } else {
      orderCubit.clearOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, List<CustomerOrder>>(
      builder: (context, state) {
        final order = state
                .firstWhereOrNull((element) => element.name == orderName)
                ?.order ??
            [];

        if (order.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(context.translate.noOrderYet),
              ),
            ),
          );
        }

        final orderedProducts = order
          ..sort(
            (o1, o2) => o1.product.sortingKey - o2.product.sortingKey,
          );
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: order.length,
                itemBuilder: (context, index) => ProductOrderTile(
                  orderName: orderName,
                  order: orderedProducts[index],
                  readOnly: readOnly,
                ),
              ),
            ),
            SumButton(
              orderName: orderName,
              onPressed: () => _onPressed(
                context,
                context.read<MultipleOrdersCubit>().state,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProductOrderTile extends StatelessWidget {
  final String orderName;
  final ProductOrder order;
  final bool readOnly;

  const ProductOrderTile({
    super.key,
    required this.orderName,
    required this.order,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: order.product.color,
      leading: Text(
        '${order.amount}',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(
        '${order.product.name} (${order.product.unit})',
        maxLines: 2,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        '${(order.amount * order.product.price).toStringAsFixed(2)}€',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: readOnly
          ? null
          : () {
              context
                  .read<OrderCubit>()
                  .removeProduct(orderName, order.product);
            },
    );
  }
}

class SumButton extends StatelessWidget {
  final String orderName;
  final bool useSafeArea;
  final double? height;
  final VoidCallback? onPressed;

  const SumButton({
    required this.orderName,
    this.useSafeArea = true,
    this.height,
    this.onPressed,
    super.key,
  });

  final textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: Colors.white,
  );

  String _getText(BuildContext context, bool multipleOrdersAllowed) {
    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      return context.translate.doOrder;
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      return context.translate.finish;
    } else {
      return context.translate.sum;
    }
  }

  Color _getColor(BuildContext context, bool multipleOrdersAllowed) {
    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      return Colors.blue;
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      return Colors.green;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultipleOrdersCubit, bool>(
      builder: (context, multipleOrdersAllowed) {
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: (useSafeArea
                          ? MediaQuery.of(context).padding.bottom
                          : 0) +
                      (height ?? 80),
                  color: _getColor(context, multipleOrdersAllowed),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getText(context, multipleOrdersAllowed)
                              .toUpperCase(),
                          style: textStyle,
                        ),
                        BlocBuilder<OrderCubit, List<CustomerOrder>>(
                          builder: (context, orders) {
                            final order = orders
                                .firstWhere(
                                    (element) => element.name == orderName)
                                .order;
                            return Text(
                              '${order.sum.toStringAsFixed(2)}€',
                              style: textStyle,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SubtotalButton extends StatelessWidget {
  final String orderName;
  final bool useSafeArea;
  final double? height;
  final VoidCallback? onPressed;

  const SubtotalButton({
    required this.orderName,
    this.useSafeArea = true,
    this.height,
    this.onPressed,
    super.key,
  });

  final textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height:
                  (useSafeArea ? MediaQuery.of(context).padding.bottom : 0) +
                      (height ?? 40),
              color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translate.splitBill.toUpperCase(),
                      style: textStyle,
                    ),
                    BlocBuilder<OrderCubit, List<CustomerOrder>>(
                      builder: (context, orders) {
                        final order = orders
                            .firstWhere((element) => element.name == orderName)
                            .order;
                        return Text(
                          '${order.sum.toStringAsFixed(2)}€',
                          style: textStyle,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
