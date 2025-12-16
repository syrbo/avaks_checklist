import '../models/checklist.dart';
import '../models/item_type.dart';
import 'package:intl/intl.dart';

class ChecklistExporter {

  static String exportToText(Checklist checklist) {
    final buffer = StringBuffer();

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);

    buffer.writeln(checklist.title);
    buffer.writeln('Создано: ${formatted}');
    buffer.writeln();

    for (final item in checklist.items) {
      switch (item.type) {
        case ItemType.header:
          buffer.writeln(item.text);
          buffer.writeln();
          break;

        case ItemType.check:
          final mark = item.done ? '✓' : '×';
          buffer.writeln('- ${item.text} [$mark]');
          break;

        case ItemType.number:
          final value = item.numberValue?.toString() ?? '×';
          buffer.writeln('- ${item.text} [$value]');
          break;

        case ItemType.voice:
        case ItemType.media:
          if (item.filePath != null) {
            final pathParts = item.filePath!.split('/');
            final fileName = pathParts.isNotEmpty ? pathParts.last : item.filePath;
            buffer.writeln('- ${item.text} [Файл: $fileName]');
          } else {
            buffer.writeln('- ${item.text} [×]');
          }
          break;
      }
    }

    return buffer.toString();
  }
}