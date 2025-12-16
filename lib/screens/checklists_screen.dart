import 'dart:io';
import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../services/internal_storage_service.dart';
import '../services/checklist_parser.dart';
import '../main.dart';
import 'checklist_run_screen.dart';
import 'package:file_picker/file_picker.dart';


class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen>
    with RouteAware {
  List<Checklist> allChecklists = [];
  String selectedCategory = 'Все';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);

    final files = await InternalStorageService.getAllChecklists();

    final loaded = <Checklist>[];

    for (final file in files) {
      final text = await file.readAsString();
      loaded.add(ChecklistParser.parse(text));
    }

    setState(() {
      allChecklists = loaded;
      isLoading = false;
    });
  }

  List<String> get categories {
    final set = <String>{'Все'};
    for (var c in allChecklists) {
      set.add(c.category);
    }
    return set.toList();
  }

  List<Checklist> get filteredChecklists {
    if (selectedCategory == 'Все') return allChecklists;
    return allChecklists
        .where((c) => c.category == selectedCategory)
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: const Text('Чек-листы')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 8),

          SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 10,
                right: 10
            ),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: RefreshIndicator(
                    onRefresh: load,
                    child: filteredChecklists.isEmpty
                        ? ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('Чек-листов нет')),
                      ],
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredChecklists.length,
                      itemBuilder: (context, i) {
                        final item = filteredChecklists[i];

                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChecklistRunScreen(checklist: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: FloatingActionButton(
                    elevation: 0,
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['md'],
                      );
                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        await InternalStorageService.saveFile(file);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Файл импортирован')),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void didPopNext() {
    load();
  }
}
