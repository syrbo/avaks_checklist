import 'item_type.dart';

class ChecklistItem {
  String text;
  ItemType type;

  bool done;
  int? numberValue;
  String? filePath;

  ChecklistItem({
    required this.text,
    required this.type,
    this.done = false,
    this.numberValue,
    this.filePath,
  });
}
