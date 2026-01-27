import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/calculator/product_input.dart';
import 'package:ordermate/components/modern_app_bar.dart';
import 'package:ordermate/components/modern_bottom_nav.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/settings/settings_screen.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order/product_order_view.dart';
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.smallest.shortestSide >= 600;
                  return Scaffold(
                    extendBody: true,
                    appBar: ModernAppBar(
                      title:
                          menu?.name ?? context.translate.noProductListSelected,
                      actions: [
                        GlassIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () => _navigateToSettings(context),
                        ),
                      ],
                    ),
                    bottomNavigationBar: isTablet
                        ? null
                        : ModernBottomNav(
                            currentIndex: navIdxSnapshot.data!,
                            onTap: (idx) => _navIdx.add(idx),
                            orderName: orderName,
                          ),
                    body: Builder(
                      builder: (context) {
                        if (isTablet) {
                          return Column(
                            children: [
                              Expanded(
                                child: ProductInput(orderName: orderName),
                              ),
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.grey.shade300,
                                      Colors.grey.shade300,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.2, 0.8, 1.0],
                                  ),
                                ),
                              ),
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
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
