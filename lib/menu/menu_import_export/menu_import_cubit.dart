import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/menu_export.dart';
import 'package:uuid/uuid.dart';

part 'menu_import_state.dart';

class MenuImportCubit extends Cubit<MenuImportState> {
  MenuImportCubit() : super(MenuImportInitial());

  pickImportFile() async {
    FilePickerResult? pickedFile;
    try {
      pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } on PlatformException catch (_) {
      pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    }

    if (pickedFile == null || pickedFile.files.first.extension != 'json') {
      emit(MenuImportInitial());
      return;
    }

    emit(MenuImportRunning());

    importFile(pickedFile.files.first.path!);
  }

  void importFile(String path) {
    emit(MenuImportRunning());

    final fixedPath = path.replaceFirst('/document/raw:', '').replaceFirst('file://', '');
    final fileRef = File(fixedPath);
    try {
      final fileContent = fileRef.readAsStringSync();
      final menuExport = MenuExport.fromJson(jsonDecode(fileContent));

      final saveMenu = Menu(
        uuid: const Uuid().v4(),
        name: menuExport.menu.name,
        products: menuExport.menu.products,
      );
      emit(MenuImported(saveMenu));
    } catch (e) {
      print(e);
      emit(MenuImportFailure());
    }
  }

  void reset() {
    emit(MenuImportInitial());
  }
}
