import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_screen.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/components/dotted_divider.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/utils/constants.dart';
import 'package:ordermate/utils/extensions.dart';

class ProductInput extends StatelessWidget {
  final String orderName;

  const ProductInput({required this.orderName, super.key});

  void _navigateToMenuSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MenuSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuSelectionCubit, Menu?>(
      builder: (context, menu) {
        if (menu == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusPill,
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: AppConstants.iconSizeXL,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingXXL),
                  Text(
                    context.translate.noProductListSelectedDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingXXL),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToMenuSelection(context),
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(context.translate.goToSettings),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return BlocBuilder<InputColumnsCubit, int>(
          builder: (context, inputColumnCount) {
            // Bottom padding to account for the ModernBottomNav
            final bottomNavPadding =
                MediaQuery.of(context).padding.bottom + AppConstants.spacingM;

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                for (
                  int sectionIdx = 0;
                  sectionIdx < menu.products.displaySectionCount;
                  sectionIdx++
                ) ...[
                  SliverGrid.count(
                    crossAxisCount: inputColumnCount,
                    childAspectRatio: inputColumnCount.toDouble(),
                    children: [
                      for (final product in menu.products.getSectionSublist(
                        sectionIdx,
                      )) ...[
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
                        padding: EdgeInsets.symmetric(
                          vertical: AppConstants.spacingS,
                        ),
                        child: DottedDivider(color: Colors.grey),
                      ),
                    ),
                ],
                // Bottom spacing for the floating bottom nav
                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomNavPadding),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ProductSelectionItem extends StatefulWidget {
  final String orderName;
  final Product product;

  const ProductSelectionItem({
    super.key,
    required this.orderName,
    required this.product,
  });

  @override
  State<ProductSelectionItem> createState() => _ProductSelectionItemState();
}

class _ProductSelectionItemState extends State<ProductSelectionItem> {
  bool _isPressed = false;
  DateTime? _pressStartTime;

  void _handleTapDown(TapDownDetails _) {
    _pressStartTime = DateTime.now();
    setState(() => _isPressed = true);
  }

  Future<void> _handleTapUp(TapUpDetails _) async {
    // Ensure the animation is visible for at least the animation duration
    final elapsed = DateTime.now().difference(_pressStartTime!);
    final remaining = AppConstants.animationFast - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (mounted) {
      setState(() => _isPressed = false);
      context.read<OrderCubit>().addProduct(
            widget.orderName,
            widget.product,
          );
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final color = product.color;

    return Padding(
      padding: EdgeInsets.all(0.2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: AppConstants.animationFast,
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              color: color.withValues(alpha: AppConstants.opacityStrong),
              border: Border.all(color: color, width: AppConstants.borderWidth),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacingS),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: color
                              .withValues(alpha: AppConstants.opacityStrong)
                              .foregroundTextColor,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.spacingXS),
                      Text(
                        product.unit,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color
                              .withValues(alpha: AppConstants.opacityStrong)
                              .foregroundTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
                for (
                  var idx = i * crossAxisCount;
                  idx < (i + 1) * crossAxisCount;
                  idx++
                )
                  if (idx <= itemCount - 1)
                    Expanded(child: itemBuilder(context, idx))
                  else
                    Expanded(child: Container()),
              ],
            ),
          ),
      ],
    );
  }
}
