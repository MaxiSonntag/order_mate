import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ordermate/l10n/app_localizations.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/order/product_order.dart';

extension ColorX on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString, {bool isLight = false}) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      if (isLight) {
        buffer.write('9b');
      } else {
        buffer.write('ff');
      }
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String get hexString {
    String toHex(double v) =>
        (v * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${toHex(a)}${toHex(r)}${toHex(g)}${toHex(b)}';
  }

  /// Returns either Colors.black or Colors.white, whichever is more readable
  /// on top of this color.
  Color get foregroundTextColor {
    // Relative luminance per WCAG (sRGB -> linear -> luminance)
    double toLinear(double v) {
      return (v <= 0.03928)
          ? (v / 12.92)
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    final rLinear = toLinear(r);
    final gLinear = toLinear(g);
    final bLinear = toLinear(b);
    final luminance = 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;

    // Contrast ratio with white/black (WCAG)
    final contrastWithWhite = (1.0 + 0.05) / (luminance + 0.05);
    final contrastWithBlack = (luminance + 0.05) / (0.0 + 0.05);

    return (contrastWithWhite >= contrastWithBlack)
        ? Colors.white
        : Colors.black;
  }

  /// Basically the opposite of foregroundTextColor
  Color get textSurfaceColor {
    // Relative luminance per WCAG (sRGB -> linear -> luminance)
    double toLinear(double v) {
      return (v <= 0.03928)
          ? (v / 12.92)
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    final rLinear = toLinear(r);
    final gLinear = toLinear(g);
    final bLinear = toLinear(b);
    final luminance = 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;

    // Contrast ratio with white/black (WCAG)
    final contrastWithWhite = (1.0 + 0.05) / (luminance + 0.05);
    final contrastWithBlack = (luminance + 0.05) / (0.0 + 0.05);

    return (contrastWithWhite >= contrastWithBlack)
        ? Colors.black
        : Colors.white;
  }
}

extension OrdersSum on List<ProductOrder> {
  double get sum {
    return fold(0, (sum, order) => sum + order.amount * order.product.price);
  }

  int get productCount {
    return fold(0, (sum, order) => sum + order.amount);
  }
}

extension Translate on BuildContext {
  AppLocalizations get translate => AppLocalizations.of(this)!;
}

extension ProductListX on List<Product> {
  List<int> get displaySectionEndIndexes => asMap()
      .entries
      .where((productEntry) => productEntry.value.isSectionEnd)
      .map((productEntry) => productEntry.key)
      .toList();

  int get displaySectionCount => displaySectionEndIndexes.length + 1;

  List<Product> getSectionSublist(int sectionIdx) {
    if (displaySectionCount == 1) {
      return this;
    }

    if (sectionIdx == 0) {
      return sublist(0, displaySectionEndIndexes.first+1);
    }

    if (sectionIdx+1 == displaySectionCount) {
      return sublist(displaySectionEndIndexes[sectionIdx-1]+1, length);
    }

    return sublist(displaySectionEndIndexes[sectionIdx-1]+1,
        displaySectionEndIndexes[sectionIdx]+1);
  }
}
