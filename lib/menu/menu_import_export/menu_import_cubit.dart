import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/menu_export.dart';
import 'package:uuid/uuid.dart';

part 'menu_import_state.dart';

class MenuImportCubit extends Cubit<MenuImportState> {
  MenuImportCubit() : super(MenuImportInitial());

  pickImportFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (pickedFile == null) {
      emit(MenuImportInitial());
      return;
    }

    emit(MenuImportRunning());

    final fileRef = File(pickedFile!.files.first.path!);
    try {
      final fileContent = fileRef.readAsStringSync();
      final menuExport = MenuExport.fromJson(jsonDecode(fileContent));

      final saveMenu = Menu(
        uuid: const Uuid().v4(),
        name: menuExport.menu.name,
        products: menuExport.menu.products,
      );
      emit(MenuImported(saveMenu));
    } catch (_) {
      emit(MenuImportFailure());
    }
  }
}
