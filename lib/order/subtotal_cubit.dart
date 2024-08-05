import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:replay_bloc/replay_bloc.dart';

class SubtotalCubit extends ReplayCubit<
    ({
      List<ProductOrder> availableProducts,
      List<ProductOrder> subtotalProducts
    })> {
  SubtotalCubit({required this.availableProducts})
      : super((
          availableProducts: availableProducts,
          subtotalProducts: <ProductOrder>[],
        ));

  final List<ProductOrder> availableProducts;

  void addToSubtotal(Product product) {
    // Decrement or remove product from available
    final orderForProductIdx =
        state.availableProducts.indexWhere((order) => order.product == product);
    final orderForProduct = state.availableProducts[orderForProductIdx];
    final updatedOrderForProduct =
        orderForProduct.copyWith(amount: orderForProduct.amount - 1);
    List<ProductOrder> updatedAvailableProducts = [...state.availableProducts];
    if (updatedOrderForProduct.amount == 0) {
      updatedAvailableProducts.removeAt(orderForProductIdx);
    } else {
      updatedAvailableProducts[orderForProductIdx] = updatedOrderForProduct;
    }

    // Increment or add product to subtotal
    final subtotalOrderForProductIdx =
        state.subtotalProducts.indexWhere((order) => order.product == product);
    List<ProductOrder> updatedSubtotalProducts = [...state.subtotalProducts];
    if (subtotalOrderForProductIdx == -1) {
      updatedSubtotalProducts.add(ProductOrder(product, 1));
    } else {
      final currentAmount =
          updatedSubtotalProducts[subtotalOrderForProductIdx].amount;
      updatedSubtotalProducts[subtotalOrderForProductIdx] =
          updatedSubtotalProducts[subtotalOrderForProductIdx]
              .copyWith(amount: currentAmount + 1);
    }

    // Return updated result
    return emit((
      availableProducts: updatedAvailableProducts,
      subtotalProducts: updatedSubtotalProducts,
    ));
  }

  void removeFromSubtotal(Product product) {
    // Decrement or remove product from subtotal
    final subtotalOrderForProductIdx =
        state.subtotalProducts.indexWhere((order) => order.product == product);
    final subtotalOrderForProduct =
        state.subtotalProducts[subtotalOrderForProductIdx];
    final updatedSubtotalOrderForProduct = subtotalOrderForProduct.copyWith(
        amount: subtotalOrderForProduct.amount - 1);
    List<ProductOrder> updatedSubtotalProducts = [...state.subtotalProducts];
    if (updatedSubtotalOrderForProduct.amount == 0) {
      updatedSubtotalProducts.removeAt(subtotalOrderForProductIdx);
    } else {
      updatedSubtotalProducts[subtotalOrderForProductIdx] =
          updatedSubtotalOrderForProduct;
    }

    // Increment or add product to available
    final orderForProductIdx =
        state.availableProducts.indexWhere((order) => order.product == product);
    List<ProductOrder> updatedOrderProducts = [...state.availableProducts];
    if (orderForProductIdx == -1) {
      updatedOrderProducts.add(ProductOrder(product, 1));
    } else {
      final currentAmount = updatedOrderProducts[orderForProductIdx].amount;
      updatedOrderProducts[orderForProductIdx] =
          updatedOrderProducts[orderForProductIdx]
              .copyWith(amount: currentAmount + 1);
    }

    // Return updated result
    return emit((
      availableProducts: updatedOrderProducts,
      subtotalProducts: updatedSubtotalProducts,
    ));
  }
}
