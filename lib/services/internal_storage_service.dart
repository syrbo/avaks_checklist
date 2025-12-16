import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InternalStorageService {
  static Future<Directory> getChecklistDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory("${dir.path}/checklists");

    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    return folder;
  }

  static Future<List<File>> getAllChecklists() async {
    final dir = await getChecklistDir();
    final files = dir
        .listSync()
        .where((e) => e is File && e.path.endsWith('.md'))
        .map((e) => File(e.path))
        .toList();

    return files;
  }

  static Future<void> saveFile(File file) async {
    final dir = await getChecklistDir();
    final name = file.uri.pathSegments.last;
    await file.copy("${dir.path}/$name");
  }
}
