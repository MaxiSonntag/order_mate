/// Centralized semantics identifiers used for UI automation (Maestro).
///
/// Keep all IDs stable once they are used in flows.
class AppSemanticsIds {
  const AppSemanticsIds._();

  // Shared app bar controls.
  static const appBarBackButton = 'app_bar.back_button';
  static const appBarSettingsButton = 'app_bar.settings_button';

  // Product input / calculator.
  static const productInputGoToSettingsButton = 'product_input.go_to_settings';
  static const bottomNavProductsTab = 'bottom_nav.products_tab';
  static const bottomNavOrderTab = 'bottom_nav.order_tab';
  static const orderSumButton = 'order.sum_button';

  // Menu selection + import flow.
  static const menuSelectionAddOrImportButton = 'menu_selection.add_or_import';
  static const menuSelectionImportOption = 'menu_selection.import_option';
  static const menuSelectionImportedProductCount =
      'menu_selection.imported_product_count';
  static const menuSelectionImportedSaveButton =
      'menu_selection.imported_save_button';

  // Settings.
  static const settingsInputColumnsDropdown = 'settings.input_columns_dropdown';
  static const settingsCalculateChangeToggle =
      'settings.calculate_change_toggle';
  static const settingsProductListsTile = 'settings.product_lists_tile';

  // Change calculation sheet.
  static const changeSheetTotalTitle = 'change_sheet.total_title';
  static const changeSheetCancelButton = 'change_sheet.cancel_button';
  static String changeSheetQuickOption(double amount) {
    final normalized = amount.toStringAsFixed(2).replaceAll('.', '_');
    return 'change_sheet.quick_option.$normalized';
  }

  // Menu options + edit screens.
  static const menuOptionsEditButton = 'menu_options.edit_button';
  static const editMenuProductsHeader = 'edit_menu.products_header';
  static const editMenuProductActionsEditButton =
      'edit_menu.product_actions.edit_button';
  static const editProductSheetTitle = 'edit_product_sheet.title';
  static const editProductSheetSaveButton = 'edit_product_sheet.save_button';

  // Dynamic identifiers.
  static String productInputTile({
    required String productName,
    required String unit,
  }) {
    return 'product_input.tile.${_slug('$productName $unit')}';
  }

  static String menuSelectionMenuTile({required String menuName}) {
    return 'menu_selection.menu_tile.${_slug(menuName)}';
  }

  static String editMenuProductTile({
    required String productName,
    required String unit,
  }) {
    return 'edit_menu.product_tile.${_slug('$productName $unit')}';
  }

  static String settingsInputColumnsOption(int value) {
    return 'settings.input_columns_option.$value';
  }

  static String _slug(String input) {
    var value = input.trim().toLowerCase();
    value = value
        .replaceAll('\u00E4', 'ae')
        .replaceAll('\u00F6', 'oe')
        .replaceAll('\u00FC', 'ue')
        .replaceAll('\u00DF', 'ss');
    value = value.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    value = value.replaceAll(RegExp(r'^_+|_+$'), '');
    return value.isEmpty ? 'item' : value;
  }
}
