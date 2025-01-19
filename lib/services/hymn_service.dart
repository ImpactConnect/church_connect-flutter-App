import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hymn.dart';

class HymnService {
  static const String _bookmarksKey = 'hymn_bookmarks';
  final SharedPreferences _prefs;
  List<Hymn> _hymns = [];
  bool _isLoaded = false;

  HymnService(this._prefs);

  static Future<HymnService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HymnService(prefs);
  }

  Future<List<Hymn>> loadHymns() async {
    if (_isLoaded) return _hymns;

    try {
      final String response = await rootBundle.loadString('assets/data/hymns.json');
      final List<dynamic> hymnsJson = json.decode(response);
      _hymns = hymnsJson.map((json) => Hymn.fromJson(json)).toList();
      _isLoaded = true;
      return _hymns;
    } catch (e) {
      throw Exception('Failed to load hymns: $e');
    }
  }

  Future<List<int>> getBookmarkedHymns() async {
    final bookmarks = _prefs.getStringList(_bookmarksKey);
    if (bookmarks == null) return [];
    return bookmarks.map((s) => int.parse(s)).toList();
  }

  Future<bool> isHymnBookmarked(int hymnNumber) async {
    final bookmarks = await getBookmarkedHymns();
    return bookmarks.contains(hymnNumber);
  }

  Future<void> toggleHymnBookmark(int hymnNumber) async {
    final bookmarks = await getBookmarkedHymns();
    if (bookmarks.contains(hymnNumber)) {
      bookmarks.remove(hymnNumber);
    } else {
      bookmarks.add(hymnNumber);
    }
    await _prefs.setStringList(
      _bookmarksKey,
      bookmarks.map((n) => n.toString()).toList(),
    );
  }

  List<Hymn> searchHymns(String query) {
    if (query.isEmpty) return _hymns;

    query = query.toLowerCase();
    return _hymns.where((hymn) {
      // Try to parse the query as a number for hymn number search
      final numberQuery = int.tryParse(query);
      if (numberQuery != null) {
        return hymn.number == numberQuery;
      }

      // Search by title and first line
      return hymn.title.toLowerCase().contains(query) ||
          hymn.verses.first.toLowerCase().contains(query);
    }).toList();
  }

  Hymn? getHymnByNumber(int number) {
    try {
      return _hymns.firstWhere((hymn) => hymn.number == number);
    } catch (e) {
      return null;
    }
  }
}
