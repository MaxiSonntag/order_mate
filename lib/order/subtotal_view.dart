import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/components/action_button.dart';
import 'package:ordermate/components/modern_app_bar.dart';
import 'package:ordermate/order/order_list.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order/subtotal_cubit.dart';
import 'package:ordermate/utils/constants.dart';
import 'package:ordermate/utils/extensions.dart';

class SubtotalView extends StatelessWidget {
  const SubtotalView({required this.availableProducts, super.key});

  final List<ProductOrder> availableProducts;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubtotalCubit(availableProducts: availableProducts),
      child: Builder(
        builder: (context) {
          final canRedo = context.select<SubtotalCubit, bool>(
            (subtotalCubit) => subtotalCubit.canRedo,
          );
          final canUndo = context.select<SubtotalCubit, bool>(
            (subtotalCubit) => subtotalCubit.canUndo,
          );

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
              }
              // Wait for the next event loop to avoid navigator lock from bottom sheet
              await Future.delayed(Duration.zero);
              if (context.mounted) {
                if (returnSubtotalProducts) {
                  navigator.pop(subtotalCubit.state.subtotalProducts);
                } else {
                  navigator.pop(const <ProductOrder>[]);
                }
              }
            },
            child: Scaffold(
              appBar: ModernAppBar(
                title: context.translate.splitBill,
                showBackButton: true,
                actions: [
                  GlassIconButton(
                    icon: Icons.undo,
                    onTap: canUndo
                        ? () => context.read<SubtotalCubit>().undo()
                        : null,
                  ),
                  GlassIconButton(
                    icon: Icons.redo,
                    onTap: canRedo
                        ? () => context.read<SubtotalCubit>().redo()
                        : null,
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Material(
                      child:
                          BlocSelector<
                            SubtotalCubit,
                            ({
                              List<ProductOrder> availableProducts,
                              List<ProductOrder> subtotalProducts,
                            }),
                            List<ProductOrder>
                          >(
                            selector: (state) => state.availableProducts,
                            builder: (context, state) {
                              return OrderList(
                                useBottomGradient: true,
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
                  const Divider(height: 8),
                  Expanded(
                    child: Material(
                      child: BlocSelector<
                        SubtotalCubit,
                        ({
                          List<ProductOrder> availableProducts,
                          List<ProductOrder> subtotalProducts,
                        }),
                        List<ProductOrder>
                      >(
                        selector: (state) => state.subtotalProducts,
                        builder: (context, state) {
                          return OrderList(
                            useTopGradient: true,
                            useBottomGradient: true,
                            order: state,
                            emptyHintText:
                                context.translate.splitBillNoProducts,
                            onTap: (product) => context
                                .read<SubtotalCubit>()
                                .removeFromSubtotal(product),
                          );
                        },
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final subtotalOrder =
                          context.select<SubtotalCubit, List<ProductOrder>>(
                        (subtotalCubit) => subtotalCubit.state.subtotalProducts,
                      );
                      final bottomPadding =
                          MediaQuery.of(context).padding.bottom;
                      return ActionButton(
                        color: AppConstants.amberAction,
                        height: AppConstants.buttonHeightLarge,
                        margin: EdgeInsets.only(
                          left: AppConstants.spacingL,
                          right: AppConstants.spacingL,
                          top: 6,
                          bottom: bottomPadding + AppConstants.spacingS,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: ActionButtonContent(
                          icon: Icons.call_split_rounded,
                          label: context.translate.splitBill,
                          trailingText:
                              '${subtotalOrder.sum.toStringAsFixed(2)}€',
                          color: AppConstants.amberAction,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _handlePop(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusPill),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacingXL,
              AppConstants.spacingL,
              AppConstants.spacingXL,
              AppConstants.spacingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.translate.splitBillConfirmTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, null),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.spacingM),
                Text(
                  context.translate.splitBillQuestion,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXXL),
                ActionButton(
                  color: AppConstants.errorAction,
                  height: AppConstants.buttonHeightStandard,
                  useSafeArea: false,
                  margin: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context, false),
                  child: ActionButtonContent(
                    icon: Icons.delete_outline,
                    label: context.translate.splitBillBackAndDelete,
                    color: AppConstants.errorAction,
                  ),
                ),
                SizedBox(height: AppConstants.spacingM),
                ActionButton(
                  color: AppConstants.amberAction,
                  height: AppConstants.buttonHeightStandard,
                  useSafeArea: false,
                  margin: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context, true),
                  child: ActionButtonContent(
                    icon: Icons.call_split_rounded,
                    label: context.translate.splitBillConfirm,
                    color: AppConstants.amberAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return result;
  }
}
