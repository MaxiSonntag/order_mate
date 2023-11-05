part of 'menu_import_cubit.dart';

@immutable
abstract class MenuImportState {}

class MenuImportInitial extends MenuImportState {}

class MenuImportPickFile extends MenuImportState {}

class MenuImportRunning extends MenuImportState {}

class MenuImportFailure extends MenuImportState {}

class MenuImported extends MenuImportState {
  final Menu menu;

  MenuImported(this.menu);
}
