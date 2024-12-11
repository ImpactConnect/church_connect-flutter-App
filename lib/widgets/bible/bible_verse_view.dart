import 'package:flutter/material.dart';
import '../../models/bible/bible_verse.dart';

class BibleVerseView extends StatelessWidget {
  final BibleVerse verse;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;

  const BibleVerseView({
    super.key,
    required this.verse,
    required this.onShare,
    required this.onBookmark,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${verse.book} ${verse.chapter}:${verse.verse}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              verse.text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: onCopy,
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: onBookmark,
                  tooltip: 'Bookmark',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onShare,
                  tooltip: 'Share',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 