import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/menu/settings/settings_errors.dart';
import 'package:ordermate/order_overview/customer_order.dart';

class MultipleOrdersCubit extends HydratedCubit<bool> {
  final multipleOrdersKey = 'MULTIPLE_ORDERS';
  List<CustomerOrder> _currentOrder;

  MultipleOrdersCubit(List<CustomerOrder> initialOrder)
      : _currentOrder = initialOrder,
        super(false);

  void setCurrentOrder(List<CustomerOrder> order) {
    _currentOrder = order;
  }

  void toggleMultipleOrders() {
    if (_currentOrder.isNotEmpty) {
      throw multipleOrdersOpen;
    }
    emit(!state);
  }

  void publishState() {
    emit(state);
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json[multipleOrdersKey];
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {multipleOrdersKey: state};
  }
}

