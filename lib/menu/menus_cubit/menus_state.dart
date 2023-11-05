part of 'menus_cubit.dart';

@immutable
abstract class MenusState {}

class MenusInitial extends MenusState {}

class MenusLoading extends MenusState {}

class MenusLoaded extends MenusState {
  final List<Menu> menus;

  MenusLoaded(this.menus);
}

class MenusLoadingError extends MenusState {}
