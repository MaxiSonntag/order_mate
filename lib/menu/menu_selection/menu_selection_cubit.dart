import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/menu/models/menu.dart';

class MenuSelectionCubit extends HydratedCubit<Menu?> {
  MenuSelectionCubit() : super(null);

  setSelectedMenu(Menu menu) {
    emit(menu);
  }

  @override
  Menu fromJson(Map<String, dynamic> json) => Menu.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Menu? state) => state?.toJson();
}
