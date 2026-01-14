import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/components/outlined_icon_button.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_screen.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/components/dotted_divider.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/utils/extensions.dart';

class ProductInput extends StatelessWidget {
  final String orderName;

  const ProductInput({
    required this.orderName,
    super.key,
  });

  void _navigateToMenuSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MenuSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuSelectionCubit, Menu?>(
      builder: (context, menu) {
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
        return BlocBuilder<InputColumnsCubit, int>(
          builder: (context, inputColumnCount) {
            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                for (int sectionIdx = 0;
                    sectionIdx < menu.products.displaySectionCount;
                    sectionIdx++) ...[
                  SliverGrid.count(
                    crossAxisCount: inputColumnCount,
                    childAspectRatio: inputColumnCount.toDouble(),
                    children: [
                      for (final product
                          in menu.products.getSectionSublist(sectionIdx)) ...[
                        ProductSelectionItem(
                          orderName: orderName,
                          product: product,
                        ),
                      ],
                    ],
                  ),
                  if (sectionIdx < menu.products.displaySectionCount - 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: DottedDivider(color: Colors.grey),
                      ),
                    ),
                ]
              ],
            );
            return GridView.count(
              crossAxisCount: inputColumnCount,
              childAspectRatio: inputColumnCount.toDouble(),
              physics: const ClampingScrollPhysics(),
              children: [
                for (final product in menu.products)
                  ProductSelectionItem(orderName: orderName, product: product),
              ],
            );
          },
        );
      },
    );
  }
}

class ProductSelectionItem extends StatelessWidget {
  final String orderName;
  final Product product;

  const ProductSelectionItem({
    super.key,
    required this.orderName,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: product.color,
      child: BlocBuilder<MultipleOrdersCubit, bool>(
        builder: (context, multipleOrders) {
          return InkWell(
            onTap: () {
              context.read<OrderCubit>().addProduct(orderName, product);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: product.color.foregroundTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(${product.unit})',
                          style: TextStyle(
                            color: product.color.foregroundTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UnscrollableGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const UnscrollableGrid({
    super.key,
    this.crossAxisCount = 3,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final rowCount = (itemCount / crossAxisCount).ceil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rowCount; i++)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var idx = i * crossAxisCount;
                    idx < (i + 1) * crossAxisCount;
                    idx++)
                  if (idx <= itemCount - 1)
                    Expanded(
                      child: itemBuilder(context, idx),
                    )
                  else
                    Expanded(
                      child: Container(),
                    ),
              ],
            ),
          )
      ],
    );
  }
}
