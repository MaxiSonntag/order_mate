import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/calculator/product_input.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/settings/settings_screen.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order/product_order_view.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/utils/extensions.dart';

class CalculatorScreen extends StatelessWidget {
  final String orderName;
  final _navIdx = StreamController<int>();

  CalculatorScreen({
    this.orderName = OrderCubit.orderNamePlaceholder,
    super.key,
  });

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MultipleOrdersCubit>(),
          child: BlocProvider.value(
            value: context.read<InputColumnsCubit>(),
            child: const SettingsScreen(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (context.read<MultipleOrdersCubit>().state) {
      final orderCubit = context.read<OrderCubit>();
      final shouldDeleteOrder = await _showDeletionConfirmationDialog(context);
      if (shouldDeleteOrder) {
        orderCubit.removeUnfinishedOrder();
      } else {
        return false;
      }
    }
    return true;
  }

  Future<bool> _showDeletionConfirmationDialog(BuildContext context) async {
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate.unfinishedOrderDeletionWarning),
        content: Text(context.translate.unfinishedOrderDeletionWarningDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.translate.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.translate.delete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    return dialogResult ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: BlocBuilder<MenuSelectionCubit, Menu?>(
        builder: (context, menu) {
          return StreamBuilder<int>(
              stream: _navIdx.stream,
              initialData: 0,
              builder: (context, navIdxSnapshot) {
                return LayoutBuilder(builder: (context, constraints) {
                  final isTablet = constraints.smallest.shortestSide >= 600;
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        menu?.name ?? context.translate.noProductListSelected,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => _navigateToSettings(context),
                          icon: const Icon(Icons.settings),
                        )
                      ],
                    ),
                    bottomNavigationBar: isTablet
                        ? null
                        : BottomNavigationBar(
                            currentIndex: navIdxSnapshot.data!,
                            onTap: (idx) => _navIdx.add(idx),
                            items: [
                              BottomNavigationBarItem(
                                icon: const Icon(Icons.dataset),
                                label: context.translate.products,
                              ),
                              BottomNavigationBarItem(
                                icon: BlocBuilder<OrderCubit,
                                    List<CustomerOrder>>(
                                  builder: (context, customerOrders) {
                                    final order = customerOrders
                                            .firstWhereOrNull((element) =>
                                                element.name == orderName)
                                            ?.order ??
                                        [];

                                    if (order.isEmpty) {
                                      return const Icon(Icons.shopping_cart);
                                    }
                                    return Badge.count(
                                      count: order.productCount,
                                      child: const Icon(Icons.shopping_cart),
                                    );
                                  },
                                ),
                                label: context.translate.order,
                              ),
                            ],
                          ),
                    body: Builder(builder: (context) {
                      if (isTablet) {
                        return Column(
                          children: [
                            Expanded(
                              child: ProductInput(orderName: orderName),
                            ),
                            const Divider(),
                            Expanded(
                              child: ProductOrderView(orderName: orderName),
                            ),
                          ],
                        );
                      } else {
                        if (navIdxSnapshot.data! == 0) {
                          return ProductInput(orderName: orderName);
                        }

                        return ProductOrderView(orderName: orderName);
                      }
                    }),
                  );
                });
              });
        },
      ),
    );
  }
}
