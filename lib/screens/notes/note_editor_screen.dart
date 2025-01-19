import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';
import '../../services/database/database_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text =
          widget.note!.markdownContent ?? widget.note!.content;
      _lastSaved = widget.note!.updatedAt;
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content')),
      );
      return;
    }

    final note = Note(
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await DatabaseHelper().insertNote(note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving note')),
        );
      }
    }
  }

  void _shareNote() {
    Share.share(
      '${_titleController.text}\n\n${_contentController.text}',
      subject: _titleController.text,
    );
  }

  void _insertMarkdown(String markdown) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start;
    final end = selection.end;

    String newText;
    if (start < 0) {
      // No selection, append to end
      newText = text + (text.isEmpty ? markdown : '\n$markdown');
    } else {
      final beforeCursor = text.substring(0, start);
      final afterCursor = text.substring(end);
      final selectedText = text.substring(start, end);

      switch (markdown) {
        case '**':
          newText = '$beforeCursor**$selectedText**$afterCursor';
          break;
        case '*':
          newText = '$beforeCursor*$selectedText*$afterCursor';
          break;
        default:
          newText = beforeCursor + markdown + afterCursor;
      }
    }

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start < 0 ? newText.length : start + markdown.length,
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _titleController.text,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _contentController.text,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file =
          '${output.path}/note_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFile = File(file);
      await pdfFile.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file)],
        text: 'Note: ${_titleController.text}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error exporting PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNote,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_lastSaved != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Last saved ${dateFormat.format(_lastSaved!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Note Title',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Start typing...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_bold),
                          onPressed: () => _insertMarkdown('**'),
                          tooltip: 'Bold',
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_italic),
                          onPressed: () => _insertMarkdown('*'),
                          tooltip: 'Italic',
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted),
                          onPressed: () => _insertMarkdown('\n- '),
                          tooltip: 'Bullet List',
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_numbered),
                          onPressed: () => _insertMarkdown('\n1. '),
                          tooltip: 'Numbered List',
                        ),
                        IconButton(
                          icon: const Icon(Icons.title),
                          onPressed: () => _insertMarkdown('\n# '),
                          tooltip: 'Heading',
                        ),
                        IconButton(
                          icon: const Icon(Icons.code),
                          onPressed: () => _insertMarkdown('`'),
                          tooltip: 'Code',
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_quote),
                          onPressed: () => _insertMarkdown('\n> '),
                          tooltip: 'Quote',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
