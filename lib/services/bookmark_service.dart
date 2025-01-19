import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _devotionalBookmarksKey = 'devotional_bookmarks';
  final SharedPreferences _prefs;

  BookmarkService(this._prefs);

  static Future<BookmarkService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return BookmarkService(prefs);
  }

  Future<List<String>> getBookmarkedDevotionals() async {
    final bookmarks = _prefs.getStringList(_devotionalBookmarksKey);
    return bookmarks ?? [];
  }

  Future<bool> isDevotionalBookmarked(String devotionalId) async {
    final bookmarks = await getBookmarkedDevotionals();
    return bookmarks.contains(devotionalId);
  }

  Future<void> toggleDevotionalBookmark(String devotionalId) async {
    final bookmarks = await getBookmarkedDevotionals();
    if (bookmarks.contains(devotionalId)) {
      bookmarks.remove(devotionalId);
    } else {
      bookmarks.add(devotionalId);
    }
    await _prefs.setStringList(_devotionalBookmarksKey, bookmarks);
  }
}
