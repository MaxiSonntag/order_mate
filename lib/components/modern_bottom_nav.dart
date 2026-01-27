import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/utils/constants.dart';
import 'package:ordermate/utils/extensions.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String orderName;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.orderName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: AppConstants.spacingXL,
        right: AppConstants.spacingXL,
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.spacingM,
      ),
      height: AppConstants.appBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.grid_view_rounded,
              label: context.translate.products,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderCubit, List<CustomerOrder>>(
              builder: (context, customerOrders) {
                final order =
                    customerOrders
                        .firstWhereOrNull(
                          (element) => element.name == orderName,
                    )
                        ?.order ??
                        [];
                return _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: context.translate.order,
                  isSelected: currentIndex == 1,
                  badgeCount: order.isEmpty ? null : order.productCount,
                  onTap: () => onTap(1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Center(
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: AppConstants.animationFast,
          child: AnimatedContainer(
            duration: AppConstants.animationSlow,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected
                  ? AppConstants.spacingXL
                  : AppConstants.spacingL,
              vertical: AppConstants.spacingS + 2,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? primaryColor.withOpacity(AppConstants.opacitySubtle)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: AppConstants.animationSlow,
                      child: Icon(
                        widget.icon,
                        size: AppConstants.iconSizeM,
                        color: widget.isSelected
                            ? primaryColor
                            : Colors.grey.shade500,
                      ),
                    ),
                    if (widget.badgeCount != null)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          child: Text(
                            '${widget.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                AnimatedSize(
                  duration: AppConstants.animationSlow,
                  curve: Curves.easeOutCubic,
                  child: widget.isSelected
                      ? Padding(
                          padding: EdgeInsets.only(left: AppConstants.spacingS),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
