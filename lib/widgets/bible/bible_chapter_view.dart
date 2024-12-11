import 'package:flutter/material.dart';
import '../../models/bible/bible_verse.dart';

class BibleChapterView extends StatelessWidget {
  final List<BibleVerse> verses;
  final String book;
  final String chapter;
  final Function(BibleVerse) onVerseSelected;

  const BibleChapterView({
    super.key,
    required this.verses,
    required this.book,
    required this.chapter,
    required this.onVerseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chapterVerses =
        verses.where((v) => v.book == book && v.chapter == chapter).toList();

    return ListView.builder(
      itemCount: chapterVerses.length,
      itemBuilder: (context, index) {
        final verse = chapterVerses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                verse.verse,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(verse.text),
            onTap: () => onVerseSelected(verse),
          ),
        );
      },
    );
  }
}
