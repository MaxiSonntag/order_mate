import 'package:flutter/material.dart';
import 'package:ordermate/order/product_order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  String get hexString => '#${value.toRadixString(16)}';

  Color get foregroundTextColor =>
      computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
