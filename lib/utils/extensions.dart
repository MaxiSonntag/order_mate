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
  List<int> get displaySectionEndIndexes => asMap().entries
      .where((productEntry) => productEntry.value.isSectionEnd)
      .map((productEntry) => productEntry.key)
      .toList();

  int get displaySectionCount => displaySectionEndIndexes.length + 1;

  List<Product> getSectionSublist(int sectionIdx) {
    if (displaySectionCount == 1) {
      return this;
    }

    if (sectionIdx == 0) {
      return sublist(0, displaySectionEndIndexes.first + 1);
    }

    if (sectionIdx + 1 == displaySectionCount) {
      return sublist(displaySectionEndIndexes[sectionIdx - 1] + 1, length);
    }

    return sublist(
      displaySectionEndIndexes[sectionIdx - 1] + 1,
      displaySectionEndIndexes[sectionIdx] + 1,
    );
  }
}

extension SumX on double {
  /// Returns up to 4 euro amounts (in euros) that a cashier is most likely to give
  /// for a given price. Heuristics:
  /// - Prefer exact payment
  /// - Otherwise prefer “round” totals (nearest sensible multiple) using euro notes/coins
  /// - Uses typical common tender: 5, 10, 20, 50 (then 2, 100 as fallback)
  List<double> get likelyCashPayments {
    const denoms = <double>[
      0.01,
      0.02,
      0.05,
      0.10,
      0.20,
      0.50,
      1,
      2,
      5,
      10,
      20,
      50,
      100,
      200,
    ];

    int toCents(double v) => (v * 100).round();
    double toEuro(int c) => c / 100.0;

    final price = toCents(this);

    // Candidate “common” totals people hand over.
    final commonTotals = <int>{
      price, // exact
      // Round up to convenient bill/coin thresholds
      ((price / 500).ceil() * 500), // to next 5€
      ((price / 1000).ceil() * 1000), // to next 10€
      ((price / 2000).ceil() * 2000), // to next 20€
      ((price / 5000).ceil() * 5000), // to next 50€
      ((price / 10000).ceil() * 10000), // to next 100€
    };

    // Also include “next single denomination above price” (e.g., price=7.30 -> 10)
    for (final d in denoms.where((d) => d >= 0.50)) {
      final dc = toCents(d);
      if (dc >= price) commonTotals.add(dc);
    }

    bool canMakeAmount(int amount) {
      // simple greedy feasibility; for euro denominations this is sufficient here
      var remaining = amount;
      for (final d in denoms.map(toCents).toList().reversed) {
        final take = remaining ~/ d;
        remaining -= take * d;
        if (remaining == 0) return true;
      }
      return remaining == 0;
    }

    // Score: smaller overpay is better; prefer “rounder” (5/10/20/50/100) totals.
    int score(int total) {
      final overpay = total - price; // >= 0
      int roundBonus = 0;
      if (total % 10000 == 0) roundBonus += 50; // 100€
      if (total % 5000 == 0) roundBonus += 40; // 50€
      if (total % 2000 == 0) roundBonus += 30; // 20€
      if (total % 1000 == 0) roundBonus += 20; // 10€
      if (total % 500 == 0) roundBonus += 10; // 5€
      // Lower score is better: weight overpay heavily, subtract bonus.
      return overpay * 10 - roundBonus;
    }

    final candidates =
        commonTotals.where((t) => t >= price && canMakeAmount(t)).toList()
          ..sort((a, b) => score(a).compareTo(score(b)));

    // Deduplicate to 2 decimals and return up to 4.
    final out = <double>[];
    final seen = <int>{};
    for (final c in candidates) {
      if (seen.add(c)) out.add(toEuro(c));
      if (out.length == 4) break;
    }
    return out;
  }
}
