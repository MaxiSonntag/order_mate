import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/utils/hive_boxes.dart';

part 'menus_state.dart';

class MenusCubit extends Cubit<MenusState> {
  MenusCubit() : super(MenusInitial());

  Future<void> loadMenus() async {
    emit(MenusLoading());
    try {
      final menusBox = await Hive.openBox<Menu>(HiveBoxes.menus);
      final menus = menusBox.values.toList();
      emit(MenusLoaded(menus));
    } catch (e) {
      emit(MenusLoadingError());
    }
  }

  Future<void> saveMenu(Menu menu) async {
    final menusBox = await Hive.openBox<Menu>(HiveBoxes.menus);
    await menusBox.put(menu.uuid, menu);
  }

  Future<void> deleteMenu(Menu menu) async {
    final menusBox = await Hive.openBox<Menu>(HiveBoxes.menus);
    if (menusBox.containsKey(menu.uuid)) {
      await menusBox.delete(menu.uuid);
    }
  }
}
