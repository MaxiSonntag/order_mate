import 'package:hydrated_bloc/hydrated_bloc.dart';

class InputColumnsCubit extends HydratedCubit<int> {
  final inputColumnsKey = 'INPUT_COLUMNS';

  InputColumnsCubit() : super(2);

  void setInputColumns(int count) {
    emit(count);
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return json[inputColumnsKey];
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return {inputColumnsKey: state};
  }
}
