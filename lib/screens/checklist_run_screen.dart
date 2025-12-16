import 'dart:io';
import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/item_type.dart';
import 'package:file_picker/file_picker.dart';
import '../services/checklist_exporter.dart';
import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';

class ChecklistRunScreen extends StatefulWidget {
  final Checklist checklist;
  const ChecklistRunScreen({required this.checklist, super.key});

  @override
  State<ChecklistRunScreen> createState() => _ChecklistRunScreenState();
}

class _ChecklistRunScreenState extends State<ChecklistRunScreen> {
  bool _isCompleted(ChecklistItem item) {
    switch (item.type) {
      case ItemType.check:
        return item.done;
      case ItemType.number:
        return item.numberValue != null;
      case ItemType.voice:
      case ItemType.media:
        return item.filePath != null && item.filePath!.isNotEmpty;
      case ItemType.header:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.checklist.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _saveResult,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.checklist.items.length,
        itemBuilder: (context, index) {
          final item = widget.checklist.items[index];
          return _buildItem(item);
        },

      ),
    );
  }

  Future<void> _saveResult() async {
    try {
      final Uint8List zipBytes =
      Uint8List.fromList(await _buildZip());

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

      await FileSaver.instance.saveAs(
        name: 'checklist_${formattedDate}',
        bytes: zipBytes,
        fileExtension: 'zip',
        mimeType: MimeType.other,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Архив сохранён в Загрузки')),
      );
    } catch (e, st) {
      debugPrint('Ошибка ZIP: $e');
      debugPrint('$st');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении архива')),
      );
    }
  }

  Future<List<int>> _buildZip() async {
    final archive = Archive();
    final text = ChecklistExporter.exportToText(widget.checklist);
    archive.addFile(
      ArchiveFile(
        'result.txt',
        utf8.encode(text).length,
        utf8.encode(text),
      ),
    );
    for (final item in widget.checklist.items) {
      if ((item.type == ItemType.voice || item.type == ItemType.media) &&
          item.filePath != null) {
        final file = File(item.filePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final name = item.filePath!.split('/').last;

          archive.addFile(
            ArchiveFile(name, bytes.length, bytes),
          );
        }
      }
    }

    return ZipEncoder().encode(archive)!;
  }

  Widget _buildItem(ChecklistItem item) {
    final completed = _isCompleted(item);
    final textStyle = TextStyle(
      color: completed ? Colors.grey : Colors.black,

    );

    switch (item.type) {
      case ItemType.header:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            item.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        );

      case ItemType.check:
        return CheckboxListTile(
          title: Text(item.text, style: textStyle),
          value: item.done,
          onChanged: (v) => setState(() => item.done = v ?? false),
        );

      case ItemType.number:
        return ListTile(
          title: Text(item.text, style: textStyle),
          trailing: SizedBox(
            width: 40,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              onChanged: (v) => setState(() => item.numberValue = int.tryParse(v)),
            ),
          ),
        );

      case ItemType.voice:
        return ListTile(
          title: Text(item.text, style: textStyle),
          subtitle: item.filePath != null ? Text('Файл: ${item.filePath!.split('/').last}') : const Text('Файл не выбран'),
          trailing: IconButton(
            icon: const Icon(Icons.audio_file),
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3','m4a']);
              if (res != null && res.files.single.path != null) {
                setState(() => item.filePath = res.files.single.path);
              }
            },
          ),
        );

      case ItemType.media:
        return ListTile(
          title: Text(item.text, style: textStyle),
          subtitle: item.filePath != null ? Text('Изображение: ${item.filePath!.split('/').last}') : const Text('Изображение не выбрана'),
          trailing: IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(type: FileType.image);
              if (res != null && res.files.single.path != null) {
                setState(() => item.filePath = res.files.single.path);
              }
            },
          ),
        );
    }
  }
}
