// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get noProductListSelected => 'Keine Produktliste ausgewählt';

  @override
  String get noProductListSelectedDesc =>
      'Keine Produktliste ausgewählt, bitte erstelle oder importiere zuerst eine Produktliste in den Einstellungen';

  @override
  String get products => 'Produkte';

  @override
  String get order => 'Bestellung';

  @override
  String get goToSettings => 'Gehe zu Einstellungen';

  @override
  String get noOrderYet => 'Es gibt noch keine Bestellung';

  @override
  String get sum => 'Summe';

  @override
  String get finish => 'Abschliessen';

  @override
  String get doOrder => 'Bestellen';

  @override
  String get productLists => 'Produktlisten';

  @override
  String get noProductLists =>
      'Keine Produktlisten verfügbar – bitte erstelle oder importiere deine erste Produktliste';

  @override
  String get addOrImport => 'Erstellen oder importieren';

  @override
  String get addManually => 'Erstellen';

  @override
  String get import => 'Importieren';

  @override
  String get importFailed => 'Import fehlgeschlagen';

  @override
  String productCount(int count) {
    return '$count Produkte';
  }

  @override
  String get save => 'Speichern';

  @override
  String get select => 'Auswählen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get share => 'Teilen';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get deletionDisabledDesc =>
      'Löschen ist nur für nicht ausgewähle Produktlisten möglich';

  @override
  String get addProductList => 'Produktliste erstellen';

  @override
  String get name => 'Name';

  @override
  String get productRequired => 'Mindestens ein Produkt ist erforderlich';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String deleteItem(String item) {
    return '$item löschen?';
  }

  @override
  String deletionQuestion(String item) {
    return 'Bist du sicher, dass du $item löschen möchtest?';
  }

  @override
  String get editProduct => 'Produkt bearbeiten';

  @override
  String get addProduct => 'Produkt erstellen';

  @override
  String get unit => 'Einheit';

  @override
  String get price => 'Preis';

  @override
  String get color => 'Farbe';

  @override
  String get nameNotEmpty => 'Name darf nicht leer sein';

  @override
  String get invalidPriceFormat => 'Ungültiges Format';

  @override
  String get settings => 'Einstellungen';

  @override
  String get multipleOrders => 'Mehrere Bestellungen';

  @override
  String get multipleOrdersDesc =>
      'Ermöglicht die Verwaltung mehrerer Bestellungen gleichzeitig';

  @override
  String get inputColumns => 'Eingabespalten';

  @override
  String get inputColumnsDesc =>
      'Die Anzahl der Spalten für die Eingabe von Produkten zur Bestellung';

  @override
  String get editProductListsDesc => 'Wählen und Bearbeiten von Produktlisten';

  @override
  String get multipleOrdersError =>
      'Offene Bestellungen müssen abgeschlossen werden um diese Einstellung zu ändern';

  @override
  String get unfinishedOrderDeletionWarning => 'Bestellung löschen?';

  @override
  String get unfinishedOrderDeletionWarningDesc =>
      'Bist du sicher dass du die aktuelle Bestellung löschen möchtest?';

  @override
  String requiredValidationErrorMessage(String field) {
    return '$field ist erforderlich';
  }

  @override
  String get noOrdersYet => 'Du hast noch keine Bestellungen angelegt';

  @override
  String get orderName => 'Name der Bestellung';

  @override
  String get finishOrder => 'Abschließen';

  @override
  String get deleteOrder => 'Bestellung löschen?';

  @override
  String deleteOrderDesc(String orderName) {
    return 'Möchtest du $orderName wirklich löschen?';
  }

  @override
  String get splitBill => 'Rechnung teilen';

  @override
  String get splitBillNoProducts => 'Keine Produkte in Zwischensumme';

  @override
  String get splitBillConfirmTitle => 'Rechnung teilen bestätigen';

  @override
  String get splitBillQuestion => 'Produkte von Gesamtbestellung abziehen?';

  @override
  String get splitBillBackAndDelete => 'Nein, zurück & löschen';

  @override
  String get splitBillConfirm => 'Teilen';

  @override
  String get importPermissionErrorMessage =>
      'OrderMate hat keinen Zugriff auf die Datei – bitte erteile die Berechtigung oder verschiebe die Datein in einen lesbaren Ordner, der nicht auf einer externen Speicherkarte (SD-Karte) liegt (z.B. \"Downloads\")';

  @override
  String get insertDividerBelowTitle => 'Trennlinie nach diesem Produkt';

  @override
  String get insertDividerBelowDesc =>
      'So lassen sich \"Sektionen\" in der Produktauswahl erstellen';
}
