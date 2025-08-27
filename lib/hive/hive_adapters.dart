import 'package:hive_ce/hive.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/product.dart';

@GenerateAdapters([
  AdapterSpec<Product>(),
  AdapterSpec<Menu>(),
])
part 'hive_adapters.g.dart';
