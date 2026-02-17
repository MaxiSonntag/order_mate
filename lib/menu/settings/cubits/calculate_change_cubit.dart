import 'package:hydrated_bloc/hydrated_bloc.dart';

class CalculateChangeCubit extends HydratedCubit<bool> {
  final calculateChangeKey = 'CALCULATE_CHANGE';

  CalculateChangeCubit() : super(false);

  void toggleCalculateChange() {
    emit(!state);
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json[calculateChangeKey];
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {calculateChangeKey: state};
  }
}
