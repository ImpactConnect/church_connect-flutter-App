import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'package:path/path.dart' as path;

class PostService {
  final _supabase = Supabase.instance.client;

  Future<List<Post>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          users:user_id (
            full_name,
            profile_image_url
          ),
          likes:likes(count),
          comments:comments(count)
        ''')
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return response.map<Post>((post) {
      final user = post['users'] as Map<String, dynamic>;
      final likes = post['likes'] as List;
      final comments = post['comments'] as List;
      
      return Post.fromJson({
        ...post,
        'user_full_name': user['full_name'],
        'user_profile_image_url': user['profile_image_url'],
        'likes_count': likes.isEmpty ? 0 : (likes[0]['count'] as int?) ?? 0,
        'comments_count': comments.isEmpty ? 0 : (comments[0]['count'] as int?) ?? 0,
      });
    }).toList();
  }

  Future<Post> createPost({
    required String content,
    File? image,
  }) async {
    String? imageUrl;
    
    if (image != null) {
      final fileExt = path.extension(image.path);
      final fileName = '${DateTime.now().toIso8601String()}$fileExt';
      
      // Read file as bytes
      final bytes = await image.readAsBytes();
      
      await _supabase.storage
          .from('post_images')
          .uploadBinary(fileName, bytes);
          
      imageUrl = _supabase.storage
          .from('post_images')
          .getPublicUrl(fileName);
    }

    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'content': content,
          'image_url': imageUrl,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('''
          *,
          users:user_id (
            full_name,
            profile_image_url
          )
        ''')
        .single();

    final user = response['users'] as Map<String, dynamic>;
    return Post.fromJson({
      ...response,
      'user_full_name': user['full_name'],
      'user_profile_image_url': user['profile_image_url'],
      'likes_count': 0,
      'comments_count': 0,
    });
  }

  Future<void> likePost(String postId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('likes')
        .insert({
          'user_id': userId,
          'post_id': postId,
        });
  }

  Future<void> unlikePost(String postId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('likes')
        .delete()
        .match({
          'user_id': userId,
          'post_id': postId,
        });
  }
}
