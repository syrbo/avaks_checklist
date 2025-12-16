import 'checklist_item.dart';

class Checklist {
  String title;
  String category;
  String description;
  List<ChecklistItem> items;

  Checklist({
    required this.title,
    required this.category,
    required this.description,
    required this.items,
  });
}
