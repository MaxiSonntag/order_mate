import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @noProductListSelected.
  ///
  /// In en, this message translates to:
  /// **'No product list selected'**
  String get noProductListSelected;

  /// No description provided for @noProductListSelectedDesc.
  ///
  /// In en, this message translates to:
  /// **'No product list selected, please navigate to settings and select or create a product list first'**
  String get noProductListSelectedDesc;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goToSettings;

  /// No description provided for @noOrderYet.
  ///
  /// In en, this message translates to:
  /// **'No order yet'**
  String get noOrderYet;

  /// No description provided for @sum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get sum;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @doOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get doOrder;

  /// No description provided for @productLists.
  ///
  /// In en, this message translates to:
  /// **'Product lists'**
  String get productLists;

  /// No description provided for @noProductLists.
  ///
  /// In en, this message translates to:
  /// **'No product lists available – please create or import your first product list'**
  String get noProductLists;

  /// No description provided for @addOrImport.
  ///
  /// In en, this message translates to:
  /// **'Add or import'**
  String get addOrImport;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productCount(int count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @deletionDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletion is only possible for non-selected product lists'**
  String get deletionDisabledDesc;

  /// No description provided for @addProductList.
  ///
  /// In en, this message translates to:
  /// **'Add product list'**
  String get addProductList;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @productRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one product is required'**
  String get productRequired;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}?'**
  String deleteItem(String item);

  /// No description provided for @deletionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {item}?'**
  String deletionQuestion(String item);

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @nameNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name must not be empty'**
  String get nameNotEmpty;

  /// No description provided for @invalidPriceFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidPriceFormat;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @multipleOrders.
  ///
  /// In en, this message translates to:
  /// **'Multiple orders'**
  String get multipleOrders;

  /// No description provided for @multipleOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Allows management of multiple orders at once'**
  String get multipleOrdersDesc;

  /// No description provided for @inputColumns.
  ///
  /// In en, this message translates to:
  /// **'Input columns'**
  String get inputColumns;

  /// No description provided for @inputColumnsDesc.
  ///
  /// In en, this message translates to:
  /// **'The amount of columns for product input to orders'**
  String get inputColumnsDesc;

  /// No description provided for @editProductListsDesc.
  ///
  /// In en, this message translates to:
  /// **'Selection and editing of product lists'**
  String get editProductListsDesc;

  /// No description provided for @multipleOrdersError.
  ///
  /// In en, this message translates to:
  /// **'Open orders must be closed to change this setting'**
  String get multipleOrdersError;

  /// No description provided for @unfinishedOrderDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete order?'**
  String get unfinishedOrderDeletionWarning;

  /// No description provided for @unfinishedOrderDeletionWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this order?'**
  String get unfinishedOrderDeletionWarningDesc;

  /// No description provided for @requiredValidationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String requiredValidationErrorMessage(String field);

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any orders yet'**
  String get noOrdersYet;

  /// No description provided for @orderName.
  ///
  /// In en, this message translates to:
  /// **'Order name'**
  String get orderName;

  /// No description provided for @finishOrder.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishOrder;

  /// No description provided for @deleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete order?'**
  String get deleteOrder;

  /// No description provided for @deleteOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete {orderName}?'**
  String deleteOrderDesc(String orderName);

  /// No description provided for @splitBill.
  ///
  /// In en, this message translates to:
  /// **'Split bill'**
  String get splitBill;

  /// No description provided for @splitBillNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products in subtotal'**
  String get splitBillNoProducts;

  /// No description provided for @splitBillConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm split bill'**
  String get splitBillConfirmTitle;

  /// No description provided for @splitBillQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove products from order?'**
  String get splitBillQuestion;

  /// No description provided for @splitBillBackAndDelete.
  ///
  /// In en, this message translates to:
  /// **'No, back & delete'**
  String get splitBillBackAndDelete;

  /// No description provided for @splitBillConfirm.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitBillConfirm;

  /// No description provided for @importPermissionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'OrderMate can\'t access the file – please grant storage permissions or move the file into a readable folder that\'s not in an external memory card (SD-card), e.g. \"Downloads\"'**
  String get importPermissionErrorMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
