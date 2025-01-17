import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../models/bible/bible_verse.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bible/bible_constants.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  List<BibleVerse> _verses = [];
  List<BibleVerse> _filteredVerses = [];
  String _selectedBook = 'Genesis';
  String _selectedChapter = '1';
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  double _fontSize = 16.0;
  Set<String> _bookmarkedVerses = {};
  final Set<String> _highlightedVerses = {};
  bool _showBookmarks = false;
  final ScrollController _scrollController = ScrollController();
  String? _scrollToVerseId;

  @override
  void initState() {
    super.initState();
    _loadBible();
    _loadBookmarks();
  }

  Future<void> _loadBible() async {
    try {
      setState(() => _isLoading = true);
      final String response = await rootBundle.loadString('assets/data/kjv.json');
      final List<dynamic> data = json.decode(response);

      _verses = data.map((verse) => BibleVerse.fromJson(verse)).toList();
      _filterVerses();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading Bible: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarkedVerses = bookmarks.toSet();
    });
  }

  void _filterVerses() {
    setState(() {
      _filteredVerses = _verses.where((verse) {
        final matchesSearch = _searchController.text.isEmpty ||
            verse.text
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            verse.book
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesBookAndChapter =
            (verse.book == _selectedBook && verse.chapter == _selectedChapter);

        return _isSearching ? matchesSearch : matchesBookAndChapter;
      }).toList();

      if (_scrollToVerseId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToVerse());
      }
    });
  }

  void _scrollToVerse() {
    if (_scrollToVerseId == null) return;

    final index = _filteredVerses.indexWhere((verse) {
      final verseId = '${verse.book}_${verse.chapter}_${verse.verse}';
      return verseId == _scrollToVerseId;
    });

    if (index != -1) {
      _scrollController.animateTo(
        index * 50.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    _scrollToVerseId = null;
  }

  void _showBookChapterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final books = _verses.map((v) => v.book).toSet().toList()
            ..sort(BibleBooks.compareBooks);

          final chapters = _verses
              .where((v) => v.book == _selectedBook)
              .map((v) => v.chapter)
              .toSet()
              .toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBook,
                  decoration: const InputDecoration(
                    labelText: 'Book',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: books.map((book) {
                    return DropdownMenuItem(
                      value: book,
                      child: Text(book),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBook = value!;
                      _selectedChapter = '1';
                    });
                    this.setState(() {
                      _filterVerses();
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Chapter',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: chapters.map((chapter) {
                    return DropdownMenuItem(
                      value: chapter,
                      child: Text('Chapter $chapter'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChapter = value!;
                    });
                    this.setState(() {
                      _filterVerses();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTextSizeControls() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Text Size'),
            Slider(
              value: _fontSize,
              min: 12,
              max: 32,
              divisions: 10,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBookmark(BibleVerse verse) async {
    final verseId = '${verse.book}_${verse.chapter}_${verse.verse}';
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];

    setState(() {
      if (_bookmarkedVerses.contains(verseId)) {
        _bookmarkedVerses.remove(verseId);
        bookmarks.remove(verseId);
      } else {
        _bookmarkedVerses.add(verseId);
        bookmarks.add(verseId);
      }
    });

    await prefs.setStringList('bookmarks', bookmarks.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Bible...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => _filterVerses(),
              )
            : GestureDetector(
                onTap: _showBookChapterPicker,
                child: Row(
                  children: [
                    Text('$_selectedBook $_selectedChapter'),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterVerses();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _showTextSizeControls,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildVerseList(),
          _buildSearchResults(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildVerseList() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: _filteredVerses.length,
      padding: const EdgeInsets.only(bottom: 60),
      separatorBuilder: (context, index) =>
          const Divider(height: 0.2, thickness: 0.1),
      itemBuilder: (context, index) {
        final verse = _filteredVerses[index];
        final verseId = '${verse.book}_${verse.chapter}_${verse.verse}';
        final isBookmarked = _bookmarkedVerses.contains(verseId);
        final isHighlighted = _highlightedVerses.contains(verseId);

        return InkWell(
          onTap: () => _showVerseOptions(verse),
          onLongPress: () {
            setState(() {
              if (_highlightedVerses.contains(verseId)) {
                _highlightedVerses.remove(verseId);
              } else {
                _highlightedVerses.add(verseId);
              }
            });
          },
          child: Container(
            color: isHighlighted
                ? Colors.yellow.withOpacity(0.2)
                : isBookmarked
                    ? Colors.blue.withOpacity(0.05)
                    : null,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse.verse,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.text,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 1.3,
                        ),
                      ),
                      if (_isSearching) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${verse.book} ${verse.chapter}:${verse.verse}',
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBookmarked)
                  Icon(
                    Icons.bookmark,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final chapters = _verses
        .where((v) => v.book == _selectedBook)
        .map((v) => v.chapter)
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final currentChapterIndex = chapters.indexOf(_selectedChapter);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: currentChapterIndex > 0
                    ? () {
                        setState(() {
                          _selectedChapter = chapters[currentChapterIndex - 1];
                          _filterVerses();
                        });
                      }
                    : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.bookmark),
                label: Text('Bookmarks (${_bookmarkedVerses.length})'),
                onPressed: () {
                  setState(() => _showBookmarks = true);
                  _showBookmarkedVerses();
                },
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: currentChapterIndex < chapters.length - 1
                    ? () {
                        setState(() {
                          _selectedChapter = chapters[currentChapterIndex + 1];
                          _filterVerses();
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookmarkedVerses() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bookmarked Verses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _verses
                    .where((verse) => _bookmarkedVerses.contains(
                        '${verse.book}_${verse.chapter}_${verse.verse}'))
                    .map((verse) => ListTile(
                          title: Text(verse.text),
                          subtitle: Text(
                              '${verse.book} ${verse.chapter}:${verse.verse}'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedBook = verse.book;
                              _selectedChapter = verse.chapter;
                              _filterVerses();
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerseOptions(BibleVerse verse) {
    final verseId = '${verse.book}_${verse.chapter}_${verse.verse}';
    final isBookmarked = _bookmarkedVerses.contains(verseId);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Verse'),
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text:
                      '${verse.text}\n- ${verse.book} ${verse.chapter}:${verse.verse}',
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verse copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              title: Text(isBookmarked ? 'Remove Bookmark' : 'Bookmark Verse'),
              onTap: () {
                _toggleBookmark(verse);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Verse'),
              onTap: () {
                Share.share(
                  '${verse.text}\n- ${verse.book} ${verse.chapter}:${verse.verse}',
                  subject: 'Bible Verse',
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching || _searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 60,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.separated(
          itemCount: _filteredVerses.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final verse = _filteredVerses[index];
            return ListTile(
              title: Text(
                verse.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${verse.book} ${verse.chapter}:${verse.verse}'),
              onTap: () => _navigateToVerse(verse),
            );
          },
        ),
      ),
    );
  }

  void _navigateToVerse(BibleVerse verse) {
    setState(() {
      _selectedBook = verse.book;
      _selectedChapter = verse.chapter;
      _scrollToVerseId = '${verse.book}_${verse.chapter}_${verse.verse}';
      _isSearching = false;
      _searchController.clear();
      _filterVerses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
