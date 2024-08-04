import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:ordermate/order_overview/customer_order.dart';

class OrderCubit extends HydratedCubit<List<CustomerOrder>> {
  static const storageKey = 'products';
  static const orderNamePlaceholder = 'PLACEHOLDER';

  bool _multipleOrdersAllowed = false;

  OrderCubit() : super([]);

  void setMultipleOrdersAllowed(bool allowed) =>
      _multipleOrdersAllowed = allowed;

  void addProduct(String? orderName, Product product) {
    var workingList = [...state];
    int customerOrderIdx = workingList.indexWhere(
        (element) => element.name == (orderName ?? orderNamePlaceholder));
    if (customerOrderIdx == -1) {
      final emptyOrder = CustomerOrder.empty(orderName ?? orderNamePlaceholder);
      workingList.add(emptyOrder);
      customerOrderIdx = workingList.indexOf(emptyOrder);
    }

    var customerOrder = workingList[customerOrderIdx];

    final productInOrderIdx = customerOrder.order.indexWhere(
      (order) => order.product == product,
    );

    if (productInOrderIdx == -1) {
      customerOrder = customerOrder.copyWith(order: [
        ...customerOrder.order,
        ProductOrder(product, 1),
      ]);
    } else {
      var productOrder = customerOrder.order[productInOrderIdx];
      productOrder = productOrder.copyWith(amount: productOrder.amount + 1);
      final updated = [...customerOrder.order];
      updated[productInOrderIdx] = productOrder;
      customerOrder = customerOrder.copyWith(order: updated);
    }

    workingList[customerOrderIdx] = customerOrder;
    emit(workingList);
  }

  void removeProduct(String? orderName, Product product) {
    final customerOrderIdx = state.indexWhere(
        (element) => element.name == (orderName ?? orderNamePlaceholder));
    var customerOrder = state[customerOrderIdx];

    final productInOrderIdx = customerOrder.order.indexWhere(
      (order) => order.product == product,
    );

    if (customerOrder.order[productInOrderIdx].amount == 1) {
      customerOrder.order.remove(customerOrder.order[productInOrderIdx]);
    } else {
      var productOrder = customerOrder.order[productInOrderIdx];
      productOrder = productOrder.copyWith(amount: productOrder.amount - 1);
      final updated = [...customerOrder.order];
      updated[productInOrderIdx] = productOrder;
      customerOrder = customerOrder.copyWith(order: updated);
    }

    state[customerOrderIdx] = customerOrder;
    emit([...state]);
  }

  void setOrderName(String name) {
    final customerOrderIdx =
        state.indexWhere((element) => element.name == orderNamePlaceholder);
    final updated = state[customerOrderIdx].copyWith(name: name);
    state[customerOrderIdx] = updated;
    emit([...state]);
  }

  void removeUnfinishedOrder() {
    final unfinishedOrderIdx = state.indexWhere((element) => element.name == orderNamePlaceholder);
    if (unfinishedOrderIdx != -1) {
      emit([...state]..removeAt(unfinishedOrderIdx));
    }
  }

  void removeOrder(String orderName) {
    final orderIdx = state.indexWhere((element) => element.name == orderName);
    if (orderIdx != -1) {
      emit([...state]..removeAt(orderIdx));
    }
  }

  clearOrders() {
    emit(const []);
  }

  bool getIsOrderEmpty(String orderName) {
    final orderIdx = state.indexWhere((element) => element.name == orderName);
    if (orderIdx != -1) {
      return state[orderIdx].order.isEmpty;
    }
    throw 'Order $orderName does not exist';
  }

  @override
  List<CustomerOrder>? fromJson(Map<String, dynamic> json) {
    return List<Map<String, dynamic>>.from(json[storageKey])
        .map((customerOrder) => CustomerOrder.fromJson(customerOrder))
        .toList();
  }

  @override
  Map<String, dynamic>? toJson(List<CustomerOrder> state) => {
        storageKey: state
            .map(
              (customerOrder) => customerOrder.toJson(),
            )
            .toList()
      };
}
