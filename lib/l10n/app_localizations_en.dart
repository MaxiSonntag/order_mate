// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get noProductListSelected => 'No product list selected';

  @override
  String get noProductListSelectedDesc =>
      'No product list selected, please navigate to settings and select or create a product list first';

  @override
  String get products => 'Products';

  @override
  String get order => 'Order';

  @override
  String get goToSettings => 'Go to settings';

  @override
  String get noOrderYet => 'No order yet';

  @override
  String get sum => 'Sum';

  @override
  String get finish => 'Finish';

  @override
  String get doOrder => 'Order';

  @override
  String get productLists => 'Product lists';

  @override
  String get noProductLists =>
      'No product lists available – please create or import your first product list';

  @override
  String get addOrImport => 'Add or import';

  @override
  String get addManually => 'Add manually';

  @override
  String get import => 'Import';

  @override
  String get importFailed => 'Import failed';

  @override
  String productCount(int count) {
    return '$count products';
  }

  @override
  String get save => 'Save';

  @override
  String get select => 'Select';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get deletionDisabledDesc =>
      'Deletion is only possible for non-selected product lists';

  @override
  String get addProductList => 'Add product list';

  @override
  String get name => 'Name';

  @override
  String get productRequired => 'At least one product is required';

  @override
  String get unknownError => 'Unknown error';

  @override
  String deleteItem(String item) {
    return 'Delete $item?';
  }

  @override
  String deletionQuestion(String item) {
    return 'Are you sure you want to delete $item?';
  }

  @override
  String get editProduct => 'Edit product';

  @override
  String get addProduct => 'Add product';

  @override
  String get unit => 'Unit';

  @override
  String get price => 'Price';

  @override
  String get color => 'Color';

  @override
  String get nameNotEmpty => 'Name must not be empty';

  @override
  String get invalidPriceFormat => 'Invalid format';

  @override
  String get settings => 'Settings';

  @override
  String get multipleOrders => 'Multiple orders';

  @override
  String get multipleOrdersDesc =>
      'Allows management of multiple orders at once';

  @override
  String get inputColumns => 'Input columns';

  @override
  String get inputColumnsDesc =>
      'The amount of columns for product input to orders';

  @override
  String get editProductListsDesc => 'Selection and editing of product lists';

  @override
  String get multipleOrdersError =>
      'Open orders must be closed to change this setting';

  @override
  String get unfinishedOrderDeletionWarning => 'Delete order?';

  @override
  String get unfinishedOrderDeletionWarningDesc =>
      'Are you sure you want to delete this order?';

  @override
  String requiredValidationErrorMessage(String field) {
    return '$field is required';
  }

  @override
  String get noOrdersYet => 'You haven\'t added any orders yet';

  @override
  String get orderName => 'Order name';

  @override
  String get finishOrder => 'Finish';

  @override
  String get deleteOrder => 'Delete order?';

  @override
  String deleteOrderDesc(String orderName) {
    return 'Do you really want to delete $orderName?';
  }

  @override
  String get splitBill => 'Split bill';

  @override
  String get splitBillNoProducts => 'No products in subtotal';

  @override
  String get splitBillConfirmTitle => 'Confirm split bill';

  @override
  String get splitBillQuestion => 'Remove products from order?';

  @override
  String get splitBillBackAndDelete => 'No, back & delete';

  @override
  String get splitBillConfirm => 'Split';

  @override
  String get importPermissionErrorMessage =>
      'OrderMate can\'t access the file – please grant storage permissions or move the file into a readable folder that\'s not in an external memory card (SD-card), e.g. \"Downloads\"';
}
