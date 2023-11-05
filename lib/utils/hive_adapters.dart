import 'package:hive_flutter/hive_flutter.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/product.dart';

class HiveAdapters {
  static registerAdapters() {
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(MenuAdapter());
  }
}