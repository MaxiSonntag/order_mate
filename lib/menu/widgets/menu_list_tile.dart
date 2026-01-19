import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/edit_menu_screen.dart';
import 'package:ordermate/menu/menu_import_export/menu_share_repository.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menus_cubit/menus_cubit.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/utils/extensions.dart';

class MenuListTile extends StatelessWidget {
  final Menu menu;
  final bool isSelected;

  const MenuListTile({
    super.key,
    required this.menu,
    this.isSelected = false,
  });

  void _openOptionsSheet(BuildContext context, Menu menu, bool isSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MenuOptionsSheet(
        menu: menu,
        isSelected: isSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isSelected
          ? const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            )
          : null,
      title: Text(menu.name),
      onTap: () => _openOptionsSheet(
        context,
        menu,
        isSelected,
      ),
    );
  }
}

class MenuOptionsSheet extends StatelessWidget {
  final Menu menu;
  final bool isSelected;

  const MenuOptionsSheet({
    super.key,
    required this.menu,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MenuShareRepository(),
      child: Builder(builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(context.translate.select),
                onTap: () => _handleSelect(context),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.translate.edit),
                onTap: () => _handleEdit(context),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(context.translate.share),
                onTap: () => _handleShare(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(context.translate.delete),
                subtitle: isSelected
                    ? Text(
                        context.translate.deletionDisabledDesc,
                      )
                    : null,
                enabled: !isSelected,
                onTap: () => _handleDelete(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _handleSelect(BuildContext context) {
    context.read<MenuSelectionCubit>().setSelectedMenu(menu);
    Navigator.of(context).pop();
  }

  Future<void> _handleEdit(BuildContext context) async {
    final navigator = Navigator.of(context);
    final menusCubit = context.read<MenusCubit>();

    navigator.pop(context);
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => EditMenuScreen(menu: menu),
      ),
    );

    await menusCubit.loadMenus();
  }

  Future<void> _handleShare(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<MenuShareRepository>().shareMenu(menu);
    navigator.pop();
  }

  Future<void> _handleDelete(BuildContext context) async {
    final navigator = Navigator.of(context);
    final menusCubit = context.read<MenusCubit>();

    await menusCubit.deleteMenu(menu);
    menusCubit.loadMenus();
    navigator.pop();
  }
}
