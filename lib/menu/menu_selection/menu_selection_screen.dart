import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/components/action_button.dart';
import 'package:ordermate/components/modern_app_bar.dart';
import 'package:ordermate/menu/edit_menu_screen.dart';
import 'package:ordermate/menu/menu_import_export/menu_import_cubit.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menus_cubit/menus_cubit.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/widgets/menu_list_tile.dart';
import 'package:ordermate/utils/extensions.dart';

class MenuSelectionScreen extends StatelessWidget {
  const MenuSelectionScreen({super.key});

  Future<void> _openAddSheet(BuildContext context) async {
    final menuImportCubit = context.read<MenuImportCubit>();

    await showModalBottomSheet(
      context: context,
      builder: (context) => const AddMenuSheet(),
    );

    menuImportCubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: context.translate.productLists,
        showBackButton: true,
        actions: [
          GlassIconButton(
            icon: Icons.add,
            onTap: () => _openAddSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<MenuSelectionCubit, Menu?>(
        builder: (context, selectedMenu) =>
            BlocConsumer<MenusCubit, MenusState>(
          listener: (context, state) {
            if (state is MenusLoaded) {
              final currentSelection = state.menus.where(
                (element) => element.uuid == selectedMenu?.uuid,
              );
              if (currentSelection.isNotEmpty) {
                context
                    .read<MenuSelectionCubit>()
                    .setSelectedMenu(currentSelection.first);
              } else if (state.menus.isNotEmpty) {
                context
                    .read<MenuSelectionCubit>()
                    .setSelectedMenu(state.menus.first);
              }
            }
          },
          builder: (context, state) {
            if (state is MenusLoading) {
              return PartialMenusList(
                selectedMenu: selectedMenu,
                isLoading: true,
              );
            }
            if (state is MenusLoadingError || state is MenusInitial) {
              return PartialMenusList(
                selectedMenu: selectedMenu,
              );
            }

            final menus = (state as MenusLoaded).menus
              ..sort(
                (m1, m2) => m2.updatedAt.compareTo(m1.updatedAt),
              );
            return MenusList(
              selectedMenu: selectedMenu,
              menus: menus,
              onAddMenu: () => _openAddSheet(context),
            );
          },
        ),
      ),
    );
  }
}

class PartialMenusList extends StatelessWidget {
  final Menu? selectedMenu;
  final bool isLoading;

  const PartialMenusList({
    super.key,
    this.selectedMenu,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (selectedMenu != null) MenuListTile(menu: selectedMenu!),
        const SizedBox(height: 16.0),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class MenusList extends StatelessWidget {
  final Menu? selectedMenu;
  final List<Menu> menus;
  final VoidCallback onAddMenu;

  const MenusList({
    super.key,
    this.selectedMenu,
    required this.menus,
    required this.onAddMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate.noProductLists,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ActionButton(
                color: Theme.of(context).colorScheme.primary,
                height: 50,
                useSafeArea: false,
                margin: EdgeInsets.zero,
                onPressed: onAddMenu,
                child: ActionButtonContent(
                  icon: Icons.add_outlined,
                  label: context.translate.addOrImport,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: menus.length,
      itemBuilder: (context, index) => MenuListTile(
        menu: menus[index],
        isSelected: menus[index].uuid == selectedMenu?.uuid,
      ),
    );
  }
}

class AddMenuSheet extends StatelessWidget {
  const AddMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: BlocBuilder<MenuImportCubit, MenuImportState>(
          builder: (context, state) {
            if (state is MenuImportInitial) {
              return _buildSelection(context);
            }

            if (state is MenuImportPickFile || state is MenuImportRunning) {
              return _buildImportRunning();
            }

            if (state is MenuImportFailure) {
              return _buildImportFailure(context);
            }

            return _buildImported(context, (state as MenuImported).menu);
          },
        ),
      ),
    );
  }

  Widget _buildSelection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(context.translate.addManually),
          onTap: () => _navigateToEditScreen(context),
        ),
        ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: Text(context.translate.import),
          onTap: () => _handleImport(context),
        ),
      ],
    );
  }

  Widget _buildImportRunning() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildImportFailure(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 46,
              ),
              const SizedBox(height: 16.0),
              Text(context.translate.importFailed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImported(BuildContext context, Menu menu) {
    final navigator = Navigator.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 46,
        ),
        const SizedBox(height: 16.0),
        Text(
          menu.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          context.translate.productCount(menu.products.length),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final menusCubit = context.read<MenusCubit>();
                    await menusCubit.saveMenu(menu);
                    menusCubit.loadMenus();

                    navigator.pop();
                  },
                  child: Text(context.translate.save),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToEditScreen(BuildContext context) async {
    final menusCubit = context.read<MenusCubit>();
    final navigator = Navigator.of(context);

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => EditMenuScreen(),
      ),
    );

    await menusCubit.loadMenus();
  }

  Future<void> _handleImport(BuildContext context) async {
    final menuImportCubit = context.read<MenuImportCubit>();

    menuImportCubit.pickImportFile();
  }
}
