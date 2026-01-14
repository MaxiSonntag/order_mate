import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/order/order_list.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/subtotal_cubit.dart';
import 'package:ordermate/utils/extensions.dart';

class SubtotalView extends StatelessWidget {
  const SubtotalView({required this.availableProducts, super.key});

  final List<ProductOrder> availableProducts;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubtotalCubit(availableProducts: availableProducts),
      child: Builder(builder: (context) {
        final canRedo = context.select<SubtotalCubit, bool>(
            (subtotalCubit) => subtotalCubit.canRedo);
        final canUndo = context.select<SubtotalCubit, bool>(
            (subtotalCubit) => subtotalCubit.canUndo);

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) {
              return;
            }

            final navigator = Navigator.of(context);
            final subtotalCubit = context.read<SubtotalCubit>();

            if (subtotalCubit.state.subtotalProducts.isEmpty) {
              navigator.pop(const <ProductOrder>[]);
              return;
            }

            final returnSubtotalProducts = await _handlePop(context);
            if (returnSubtotalProducts == null) {
              return;
            } else if (returnSubtotalProducts) {
              navigator.pop(subtotalCubit.state.subtotalProducts);
            } else {
              navigator.pop(const []);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.translate.splitBill),
              actions: [
                IconButton(
                  onPressed: canUndo
                      ? () => context.read<SubtotalCubit>().undo()
                      : null,
                  icon: const Icon(Icons.undo),
                ),
                IconButton(
                  onPressed: canRedo
                      ? () => context.read<SubtotalCubit>().redo()
                      : null,
                  icon: const Icon(Icons.redo),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Material(
                    child: BlocSelector<
                        SubtotalCubit,
                        ({
                          List<ProductOrder> availableProducts,
                          List<ProductOrder> subtotalProducts
                        }),
                        List<ProductOrder>>(
                      selector: (state) => state.availableProducts,
                      builder: (context, state) {
                        return OrderList(
                          order: state,
                          emptyHintText: '',
                          onTap: (product) => context
                              .read<SubtotalCubit>()
                              .addToSubtotal(product),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(
                  height: 8,
                ),
                Expanded(
                  child: Material(
                    child: BlocSelector<
                        SubtotalCubit,
                        ({
                          List<ProductOrder> availableProducts,
                          List<ProductOrder> subtotalProducts
                        }),
                        List<ProductOrder>>(
                      selector: (state) => state.subtotalProducts,
                      builder: (context, state) {
                        return OrderList(
                          order: state,
                          emptyHintText: context.translate.splitBillNoProducts,
                          onTap: (product) => context
                              .read<SubtotalCubit>()
                              .removeFromSubtotal(product),
                        );
                      },
                    ),
                  ),
                ),
                SubtotalButton(
                  height: 80,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<bool?> _handlePop(BuildContext context) async {
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate.splitBillConfirmTitle),
        content: Text(context.translate.splitBillQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.translate.splitBillBackAndDelete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              context.translate.cancel,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.translate.splitBillConfirm,
              style: const TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );

    return dialogResult;
  }
}

class SubtotalButton extends StatelessWidget {
  final bool useSafeArea;
  final double? height;
  final VoidCallback? onPressed;

  const SubtotalButton({
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
    final subtotalOrder = context.select<SubtotalCubit, List<ProductOrder>>(
        (subtotalCubit) => subtotalCubit.state.subtotalProducts);

    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: height ?? 40,
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
                        Text(
                          '${subtotalOrder.sum.toStringAsFixed(2)}€',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (useSafeArea)
            Container(
              height: MediaQuery.viewPaddingOf(context).bottom,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }
}
