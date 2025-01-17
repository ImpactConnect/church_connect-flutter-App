import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blog.dart';

class BlogService {
  final _supabase = Supabase.instance.client;

  Future<List<Blog>> getBlogs({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    List<String>? tags,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      var query = _supabase
          .from('blogs')
          .select('*, blog_likes (user_id)')
          .eq('is_published', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      final List<dynamic> response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      final blogs = <Blog>[];
      
      // Process each blog sequentially
      for (final blog in response) {
        try {
          final authorId = blog['author_id'];
          final authorResponse = await _supabase
              .from('users')
              .select('id, full_name, profile_image_url')
              .eq('id', authorId)
              .single();

          final likes = blog['blog_likes'] as List<dynamic>? ?? [];
          final likesCount = likes.length;
          final isLiked = userId != null && likes.any((like) => like['user_id'] == userId);

          blogs.add(Blog.fromJson({
            ...blog,
            'author': authorResponse,
            'likes_count': likesCount,
            'is_liked_by_current_user': isLiked,
          }));
        } catch (e) {
          print('Error fetching author for blog ${blog['id']}: $e');
          blogs.add(Blog.fromJson({
            ...blog,
            'author': {
              'id': blog['author_id'],
              'full_name': 'Unknown Author',
              'profile_image_url': null,
            },
            'likes_count': 0,
            'is_liked_by_current_user': false,
          }));
        }
      }

      return blogs;
    } catch (e) {
      print('Error loading blogs: $e');
      rethrow;
    }
  }

  Future<Blog?> getBlogById(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('blogs')
          .select('*, blog_likes (user_id)')
          .eq('id', id)
          .single();

      if (response == null) return null;

      try {
        final authorId = response['author_id'];
        final authorResponse = await _supabase
            .from('users')
            .select('id, full_name, profile_image_url')
            .eq('id', authorId)
            .single();

        final likes = response['blog_likes'] as List<dynamic>? ?? [];
        final likesCount = likes.length;
        final isLiked = userId != null && likes.any((like) => like['user_id'] == userId);

        return Blog.fromJson({
          ...response,
          'author': authorResponse,
          'likes_count': likesCount,
          'is_liked_by_current_user': isLiked,
        });
      } catch (e) {
        print('Error fetching author for blog $id: $e');
        return Blog.fromJson({
          ...response,
          'author': {
            'id': response['author_id'],
            'full_name': 'Unknown Author',
            'profile_image_url': null,
          },
          'likes_count': 0,
          'is_liked_by_current_user': false,
        });
      }
    } catch (e) {
      print('Error getting blog: $e');
      return null;
    }
  }

  Future<Blog> toggleLike(Blog blog) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      if (blog.isLikedByCurrentUser) {
        // Unlike
        await _supabase
            .from('blog_likes')
            .delete()
            .eq('blog_id', blog.id)
            .eq('user_id', userId);
        
        return blog.copyWith(
          isLikedByCurrentUser: false,
          likesCount: blog.likesCount - 1,
        );
      } else {
        // Like
        await _supabase.from('blog_likes').insert({
          'blog_id': blog.id,
          'user_id': userId,
        });

        return blog.copyWith(
          isLikedByCurrentUser: true,
          likesCount: blog.likesCount + 1,
        );
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
}
