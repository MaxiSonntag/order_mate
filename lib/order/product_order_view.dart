import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/components/action_button.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/widgets/text_input_bottom_sheet.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/order/order_list.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/subtotal_view.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/utils/constants.dart';
import 'package:ordermate/utils/extensions.dart';

class ProductOrderView extends StatelessWidget {
  final String orderName;
  final bool readOnly;

  const ProductOrderView({
    this.orderName = OrderCubit.orderNamePlaceholder,
    this.readOnly = false,
    super.key,
  });

  Future<void> _onPressed(
    BuildContext context,
    bool multipleOrdersAllowed, {
    List<ProductOrder>? orders,
  }) async {
    final navigator = Navigator.of(context);
    final orderCubit = context.read<OrderCubit>();

    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      if (orderCubit.state.isNotEmpty) {
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
      }
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      if (orders == null) {
        orderCubit.removeOrder(orderName);
        navigator.pop();
      } else {
        for (final order in orders) {
          for (int i = 1; i <= order.amount; i++) {
            orderCubit.removeProduct(orderName, order.product);
          }
        }

        if (orderCubit.getIsOrderEmpty(orderName)) {
          orderCubit.removeOrder(orderName);
          navigator.pop();
        }
      }
    } else {
      if (orders == null) {
        orderCubit.clearOrders();
      } else {
        for (final order in orders) {
          for (int i = 1; i <= order.amount; i++) {
            orderCubit.removeProduct(orderName, order.product);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, List<CustomerOrder>>(
      builder: (context, state) {
        final order =
            state
                .firstWhereOrNull((element) => element.name == orderName)
                ?.order ??
            [];

        return BlocBuilder<MultipleOrdersCubit, bool>(
          builder: (context, multipleOrdersAllowed) {
            return Column(
              children: [
                Expanded(
                  child: OrderList(
                    useBottomGradient: true,
                    order: order,
                    emptyHintText: context.translate.noOrderYet,
                    readOnly: readOnly,
                    onTap: (product) {
                      context.read<OrderCubit>().removeProduct(
                        orderName,
                        product,
                      );
                    },
                  ),
                ),
                if ((!multipleOrdersAllowed ||
                        orderName != OrderCubit.orderNamePlaceholder) &&
                    order.isNotEmpty)
                  SubtotalButton(
                    orderName: orderName,
                    height: AppConstants.buttonHeightSubtotal,
                    onPressed: () async {
                      final subtotalProducts = await Navigator.of(context)
                          .push<List<ProductOrder>>(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  SubtotalView(availableProducts: order),
                            ),
                          );
                      if ((subtotalProducts?.isNotEmpty ?? false) &&
                          context.mounted) {
                        _onPressed(
                          context,
                          multipleOrdersAllowed,
                          orders: subtotalProducts,
                        );
                      }
                    },
                  ),
                SumButton(
                  orderName: orderName,
                  height: AppConstants.buttonHeightSum,
                  onPressed: () => _onPressed(
                    context,
                    context.read<MultipleOrdersCubit>().state,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ProductOrderTile extends StatefulWidget {
  final ProductOrder order;
  final bool readOnly;
  final VoidCallback? onTap;

  const ProductOrderTile({
    super.key,
    required this.order,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<ProductOrderTile> createState() => _ProductOrderTileState();
}

class _ProductOrderTileState extends State<ProductOrderTile> {
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
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.order.product;
    final color = product.color;
    final textColor = color.withValues(alpha: 0.7).foregroundTextColor;

    return GestureDetector(
      onTapDown: widget.readOnly ? null : _handleTapDown,
      onTapUp: widget.readOnly ? null : _handleTapUp,
      onTapCancel: widget.readOnly ? null : _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppConstants.animationFast,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            color: color.withValues(alpha: AppConstants.opacityStrong),
            border: Border.all(color: color, width: AppConstants.borderWidth),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            child: Row(
              children: [
                // Amount badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: product.color.textSurfaceColor.withValues(
                      alpha: AppConstants.opacityLight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.order.amount}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingM + 2),
                // Name and unit
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.unit})',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppConstants.spacingM),
                // Price
                Text(
                  '${(widget.order.amount * product.price).toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Color _getColor(bool multipleOrdersAllowed) {
    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      return AppConstants.indigoAction;
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      return AppConstants.emeraldAction;
    } else {
      return AppConstants.emeraldAction;
    }
  }

  IconData _getIcon(bool multipleOrdersAllowed) {
    if (multipleOrdersAllowed && orderName == OrderCubit.orderNamePlaceholder) {
      return Icons.receipt_long_outlined;
    } else if (multipleOrdersAllowed &&
        orderName != OrderCubit.orderNamePlaceholder) {
      return Icons.check_circle_outline;
    } else {
      return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultipleOrdersCubit, bool>(
      builder: (context, multipleOrdersAllowed) {
        final color = _getColor(multipleOrdersAllowed);
        final order = context.select<OrderCubit, List<ProductOrder>?>(
          (cubit) => cubit.state
              .firstWhereOrNull((element) => element.name == orderName)
              ?.order,
        );

        return ActionButton(
          color: color,
          height: height,
          useSafeArea: useSafeArea,
          onPressed: onPressed,
          child: ActionButtonContent(
            icon: _getIcon(multipleOrdersAllowed),
            label: _getText(context, multipleOrdersAllowed),
            trailingText: '${(order?.sum.toStringAsFixed(2) ?? '0.00')}€',
            color: color,
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

  static const _color = AppConstants.amberAction;

  const SubtotalButton({
    required this.orderName,
    this.useSafeArea = false,
    this.height,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final order = context.select<OrderCubit, List<ProductOrder>>(
      (cubit) =>
          cubit.state
              .firstWhereOrNull((element) => element.name == orderName)
              ?.order ??
          [],
    );

    return ActionButton(
      color: _color,
      height: height,
      useSafeArea: useSafeArea,
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: 6,
      ),
      onPressed: onPressed,
      child: ActionButtonContent(
        icon: Icons.call_split_rounded,
        label: context.translate.splitBill,
        trailingText: '${order.sum.toStringAsFixed(2)}€',
        color: _color,
      ),
    );
  }
}
