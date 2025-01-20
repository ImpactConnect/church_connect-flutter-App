import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ebook.dart';

class SupabaseEbookService {
  final _supabase = Supabase.instance.client;

  Future<List<Ebook>> getAllBooks({
    int page = 1,
    String? category,
    String? author,
    String sortBy = 'latest',
  }) async {
    var query = _supabase.from('ebooks').select();

    // Apply filters
    if (category != null) {
      query = query.ilike('category', category);
    }
    if (author != null) {
      query = query.ilike('author', author);
    }

    // Apply sorting and pagination
    final response = await query.range((page - 1) * 10, page * 10 - 1)
        .order(sortBy == 'popular' 
            ? 'view_count' 
            : sortBy == 'title' 
                ? 'title' 
                : 'created_at', 
          ascending: sortBy == 'title');

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }

  Future<List<Ebook>> getBookOfWeek() async {
    final response = await _supabase
        .from('ebooks')
        .select()
        .is_('is_book_of_week', true)
        .order('created_at', ascending: false);

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }

  Future<List<Ebook>> getRecommendedBooks() async {
    final response = await _supabase
        .from('ebooks')
        .select()
        .is_('is_recommended', true)
        .order('view_count', ascending: false)
        .limit(5);

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }

  Future<List<String>> getAllCategories() async {
    final response = await _supabase
        .from('ebooks')
        .select('category')
        .order('category');

    // Convert to Set to remove duplicates, then back to List
    final categories = response
        .map((item) => item['category'].toString())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    
    categories.sort();
    return categories;
  }

  Future<List<String>> getAllAuthors() async {
    final response = await _supabase
        .from('ebooks')
        .select('author')
        .order('author');

    // Convert to Set to remove duplicates, then back to List
    final authors = response
        .map((item) => item['author'].toString())
        .where((author) => author.isNotEmpty)
        .toSet()
        .toList();
    
    authors.sort();
    return authors;
  }

  Future<void> incrementViewCount(String bookId) async {
    await _supabase.rpc('increment_book_view_count', params: {'book_id': bookId});
  }

  Future<List<Ebook>> searchBooks(String query) async {
    final searchPattern = '%$query%';
    final response = await _supabase
        .from('ebooks')
        .select()
        .or('title.ilike.$searchPattern,author.ilike.$searchPattern')
        .order('created_at', ascending: false)
        .limit(20);

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }

  Future<List<Ebook>> getRelatedBooks(String bookId, String category) async {
    final response = await _supabase
        .from('ebooks')
        .select()
        .neq('id', bookId)
        .ilike('category', category)
        .order('view_count', ascending: false)
        .limit(5);

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }

  Future<List<Ebook>> getBooksByAuthor(String author) async {
    final response = await _supabase
        .from('ebooks')
        .select()
        .ilike('author', author)
        .order('created_at', ascending: false);

    return List<Ebook>.from(
      response.map((book) => Ebook.fromSupabase(book)),
    );
  }
}
