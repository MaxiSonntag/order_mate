import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/menu_export.dart';
import 'package:share_plus/share_plus.dart';

class MenuShareRepository {
  Future<void> shareMenu(Menu menu) async {
    final tempDirectory = await getTemporaryDirectory();
    final fileName =
        '${menu.name}_${DateTime.now().millisecondsSinceEpoch}.ordermate';

    final menuExport = MenuExport(1, DateTime.now(), menu);
    final fileRef = File('${tempDirectory.path}/$fileName')..createSync();
    final jsonString = jsonEncode(
      menuExport.toJson(),
    );
    final resultFile = await fileRef.writeAsString(jsonString);

    await Share.shareXFiles([XFile(resultFile.path)]);
    resultFile.deleteSync();
  }
}
