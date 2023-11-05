import 'package:flutter/widgets.dart';
import 'package:ordermate/utils/extensions.dart';

class Validators {
  static String? textNotEmpty(BuildContext context, String? text) {
    if (text == null || text.trim().isEmpty) {
      return context.translate.nameNotEmpty;
    }
    return null;
  }
}