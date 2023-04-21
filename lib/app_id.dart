import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppId {
  String _generateUniqueId() {return DateTime.now().millisecondsSinceEpoch.toString();}
  Future<String> getUniqueId() async {
    Directory tempDir = await getTemporaryDirectory();
    File idFile = File('${tempDir.path}/unique_id.txt');
    if (await idFile.exists()) {return await idFile.readAsString();}
    else {
      String uniqueId = _generateUniqueId();
      await idFile.writeAsString(uniqueId);
      return uniqueId;
    }
  }
}