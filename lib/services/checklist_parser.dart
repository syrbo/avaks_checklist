import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/item_type.dart';

class ChecklistParser {
  static Checklist parse(String text) {
    final lines = text.trim().split('\n');

    String category = 'Без категории';
    String title = 'Без названия';
    String description = '';
    final items = <ChecklistItem>[];

    for (final raw in lines) {
      final line = raw.trim();

      if (line.isEmpty) continue;

      if (line.startsWith('# Категория:')) {
        category = line.replaceFirst('# Категория:', '').trim();
        continue;
      }
      if (line.startsWith('# Название:')) {
        title = line.replaceFirst('# Название:', '').trim();
        continue;
      }
      if (line.startsWith('# Описание:')) {
        description = line.replaceFirst('# Описание:', '').trim();
        continue;
      }

      // Глава
      if (line.startsWith('^')) {
        final t = line.substring(1).trim();
        items.add(ChecklistItem(text: t, type: ItemType.header));
        continue;
      }

      // Задача
      if (line.startsWith('- ')) {
        final rawTask = line.substring(2).trim();
        items.add(_parseItem(rawTask));
        continue;
      }
    }

    return Checklist(
      title: title,
      category: category,
      description: description,
      items: items,
    );
  }

  static ChecklistItem _parseItem(String raw) {
    final typeReg = RegExp(r'\[(.+?)\]$');
    final match = typeReg.firstMatch(raw);

    String text = raw;
    ItemType type = ItemType.check;

    if (match != null) {
      final typeStr = match.group(1)!.trim().toLowerCase();
      text = raw.replaceFirst(typeReg, '').trim();

      if (['чек', 'check', 'checkbox'].contains(typeStr)) type = ItemType.check;
      else if (['число', 'number', 'num'].contains(typeStr)) type = ItemType.number;
      else if (['голос', 'voice', 'audio'].contains(typeStr)) type = ItemType.voice;
      else if (['медиа', 'media', 'image', 'img'].contains(typeStr)) type = ItemType.media;
      else type = ItemType.check;
    }

    return ChecklistItem(text: text, type: type);
  }
}
