import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/hymn.dart';
import '../../services/hymn_service.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({
    super.key,
    required this.hymn,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late HymnService _hymnService;
  bool _isBookmarked = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initializeHymnService();
  }

  Future<void> _initializeHymnService() async {
    _hymnService = await HymnService.create();
    final isBookmarked = await _hymnService.isHymnBookmarked(widget.hymn.number);
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  void _shareHymn() {
    final verses = widget.hymn.verses.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final verse = entry.value;
      return '\nVerse $index:\n$verse';
    }).join('\n');

    final chorus = widget.hymn.chorus != null
        ? '\nChorus:\n${widget.hymn.chorus}\n'
        : '';

    final text = '''
Hymn ${widget.hymn.number}: ${widget.hymn.title}
By ${widget.hymn.author}
$verses
$chorus
''';

    Share.share(text);
  }

  Future<void> _toggleBookmark() async {
    await _hymnService.toggleHymnBookmark(widget.hymn.number);
    final isBookmarked = await _hymnService.isHymnBookmarked(widget.hymn.number);
    setState(() {
      _isBookmarked = isBookmarked;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBookmarked ? 'Hymn bookmarked' : 'Bookmark removed',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn ${widget.hymn.number}'),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareHymn,
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (size) {
              setState(() {
                _fontSize = size;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 14.0,
                child: Text('Small Text'),
              ),
              const PopupMenuItem(
                value: 16.0,
                child: Text('Medium Text'),
              ),
              const PopupMenuItem(
                value: 18.0,
                child: Text('Large Text'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hymn.title,
              style: TextStyle(
                fontSize: _fontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${widget.hymn.author}',
              style: TextStyle(
                fontSize: _fontSize - 2,
                color: Colors.grey[600],
              ),
            ),
            if (widget.hymn.tune != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tune: ${widget.hymn.tune}',
                style: TextStyle(
                  fontSize: _fontSize - 2,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ...widget.hymn.verses.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final verse = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verse $index',
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verse,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.5,
                    ),
                  ),
                  if (widget.hymn.chorus != null &&
                      index != widget.hymn.verses.length)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Chorus',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.hymn.chorus!,
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
