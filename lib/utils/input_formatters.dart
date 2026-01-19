import 'package:flutter/services.dart';

class SignedDecimalFormatter extends TextInputFormatter {
  SignedDecimalFormatter({this.decimalRange = 2});
  final int decimalRange;

  static const _transient = {'', '-', '.', '-.', ',', '-,'};

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final raw = newValue.text;

    // Allow transient edit states (important for sign/decimal entry flows).
    if (_transient.contains(raw)) return newValue;

    // Validate against a normalized view, but don't necessarily rewrite raw text yet.
    final norm = raw.replaceAll(',', '.');

    // Only digits, one optional leading '-', and at most one '.'.
    if (!_onlyValidChars(norm)) return oldValue;
    if (_hasSecondMinus(norm)) return oldValue;

    final parts = norm.split('.');
    if (parts.length > 2) return oldValue; // blocks multiple dots, always

    if (parts.length == 2 && parts[1].length > decimalRange) return oldValue;

    // If IME is composing, do not rewrite ','->'.' (can break Samsung/Gboard composition),
    // but we already enforced the rules above.
    if (!newValue.composing.isCollapsed) return newValue;

    // Safe to normalize when not composing.
    if (raw != norm) {
      final offset = newValue.selection.baseOffset.clamp(0, norm.length);
      return newValue.copyWith(
        text: norm,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty,
      );
    }

    return newValue;
  }

  bool _onlyValidChars(String s) {
    for (final codeUnit in s.codeUnits) {
      final c = String.fromCharCode(codeUnit);
      final isDigit = codeUnit >= 0x30 && codeUnit <= 0x39;
      if (!(isDigit || c == '.' || c == '-')) return false;
    }
    return true;
  }

  bool _hasSecondMinus(String s) => s.indexOf('-', 1) != -1;
}
