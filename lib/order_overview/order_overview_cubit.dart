import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/order_overview/customer_order.dart';

class OrderOverviewCubit extends HydratedCubit<List<CustomerOrder>> {
  bool _isMultpleOrdersAllowed;

  OrderOverviewCubit(bool isMultpleOrdersAllowed)
      : _isMultpleOrdersAllowed = isMultpleOrdersAllowed,
        super(const []);

  void setMultipleOrdersAllowed(bool allowed) {
    _isMultpleOrdersAllowed = allowed;
  }

  void addCustomerOrder(CustomerOrder order) {
    if (_isMultpleOrdersAllowed) {
      if (state.indexWhere((element) => element.name == order.name) != -1) {
        throw CustomerOrderError.duplicateOrderName;
      }

      emit([order, ...state]);
    } else {
      emit([order]);
    }
  }

  void removeOrder(CustomerOrder order) {
    state.remove(order);
    emit(state);
  }

  @override
  List<CustomerOrder>? fromJson(Map<String, dynamic> json) {
    final List<CustomerOrder> customerOrders = [];
    json.forEach((name, order) {
      customerOrders.add(CustomerOrder(name: name, order: order));
    });
    return customerOrders;
  }

  @override
  Map<String, dynamic>? toJson(List<CustomerOrder> state) => {
        for (var customerOrder in state) customerOrder.name: customerOrder.order
      };
}
