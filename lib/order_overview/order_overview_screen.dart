import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/calculator/calculator_screen.dart';
import 'package:ordermate/components/outlined_icon_button.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_screen.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/settings/settings_screen.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order/product_order_view.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/utils/extensions.dart';

class OrderOverviewScreen extends StatelessWidget {
  const OrderOverviewScreen({super.key});

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

  void _navigateToMenuSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MenuSelectionScreen(),
      ),
    );
  }

  void _navigateToCalculator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MultipleOrdersCubit>(),
          child: BlocProvider.value(
            value: context.read<MenuSelectionCubit>(),
            child: BlocProvider.value(
              value: context.read<OrderCubit>(),
              child: CalculatorScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openOrderActionsSheet(BuildContext context, CustomerOrder order) async {
    final finishActionColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.monetization_on_outlined,
                color: finishActionColor,
              ),
              title: Text(
                context.translate.finishOrder,
                style: TextStyle(color: finishActionColor),
              ),
              onTap: () => _openFinishOrderScreen(context, order),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.translate.delete),
              onTap: () => _deleteOrder(context, order),
            ),
          ],
        ),
      ),
    );
  }

  void _openFinishOrderScreen(BuildContext context, CustomerOrder order) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MultipleOrdersCubit>(),
          child: BlocProvider.value(
            value: context.read<MenuSelectionCubit>(),
            child: BlocProvider.value(
              value: context.read<OrderCubit>(),
              child: Scaffold(
                appBar: AppBar(
                  title: Text(order.name),
                ),
                body: ProductOrderView(
                  readOnly: true,
                  orderName: order.name,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteOrder(BuildContext context, CustomerOrder order) async {
    final orderCubit = context.read<OrderCubit>();
    final navigator = Navigator.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate.deleteOrder),
        content: Text(context.translate.deleteOrderDesc(order.name)),
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

    if (shouldDelete != null && shouldDelete) {
      orderCubit.removeOrder(order.name);
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuSelectionCubit, Menu?>(
      builder: (context, menu) {
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
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _navigateToCalculator(context),
          ),
          body: Builder(
            builder: (context) {
              if (menu == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.translate.noProductListSelectedDesc,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12.0),
                        OutlinedIconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => _navigateToMenuSelection(context),
                          child: Text(context.translate.goToSettings),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return BlocBuilder<OrderCubit, List<CustomerOrder>>(
                builder: (context, customerOrders) {
                  if (customerOrders.isEmpty) {
                    return Center(
                      child: Text(context.translate.noOrdersYet),
                    );
                  }
                  return ListView(
                    children: [
                      for (final customerOrder in customerOrders)
                        ListTile(
                          title: Text(customerOrder.name),
                          subtitle: Text(
                            context.translate.productCount(
                              customerOrder.order.productCount,
                            ),
                          ),
                          onTap: () =>
                              _openOrderActionsSheet(context, customerOrder),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
