import 'dart:io';

class FileService {
  static Future<List<File>> getMdFiles(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();
  }

  static Future<String> readFile(File file) async {
    return file.readAsString();
  }
}
