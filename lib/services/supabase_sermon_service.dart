import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sermon.dart';
import '../models/sermon_categories.dart';
import 'package:flutter/material.dart';
import 'download_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SupabaseSermonService {
  final _supabase = Supabase.instance.client;
  static const _storageSermonsBucket = 'sermons';
  static const _pageSize = 10;

  // Keys for SharedPreferences
  static const String _favoriteSermonsKey = 'favorite_sermons';
  static const String _downloadedSermonsKey = 'downloaded_sermons';

  String? get _userId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  Future<Set<String>> _getFavoriteSermonIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteSermonsKey)?.toSet() ?? {};
  }

  Future<void> _saveFavoriteSermonIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteSermonsKey, ids.toList());
  }

  Future<Map<String, String>> _getDownloadedSermons() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_downloadedSermonsKey);
    if (jsonStr == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> _saveDownloadedSermons(Map<String, String> downloads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadedSermonsKey, jsonEncode(downloads));
  }

  Future<List<Sermon>> getSermons({
    String? series,
    List<String>? topics,
    String? category,
    String? preacher,
    required int page,
  }) async {
    try {
      print(
          'Fetching sermons with params: series=$series, topics=$topics, preacher=$preacher, page=$page');

      var queryBuilder = _supabase.from('sermons').select();

      if (series != null) {
        queryBuilder = queryBuilder.filter('series_name', 'ilike', series);
      }

      if (preacher != null) {
        queryBuilder = queryBuilder.filter('preacher', 'ilike', preacher);
      }

      if (topics != null && topics.isNotEmpty) {
        queryBuilder = queryBuilder.filter('tags', 'ov', topics);
      }

      final response = await queryBuilder
          .order('sermon_date', ascending: false)
          .range((page - 1) * _pageSize, page * _pageSize - 1);

      print('Raw response type: ${response.runtimeType}');
      print('Raw response: $response');

      if (response.isEmpty) {
        print('No sermons found in response');
        return [];
      }

      print('Number of sermons in response: ${response.length}');

      final sermons = response
          .map((data) {
            try {
              print('Processing sermon data: $data');
              final sermon = Sermon.fromSupabase(data);
              print('Successfully created sermon: ${sermon.title}');
              return sermon;
            } catch (e, stackTrace) {
              print('Error parsing sermon data: $e');
              print('Stack trace: $stackTrace');
              print('Problematic data: $data');
              return null;
            }
          })
          .whereType<Sermon>()
          .toList();

      print('Successfully parsed ${sermons.length} sermons');
      return sermons;
    } catch (e, stackTrace) {
      print('Error fetching sermons: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Sermon?> getSermonById(String id) async {
    try {
      print('Fetching sermon with ID: $id');
      final response =
          await _supabase.from('sermons').select('*').eq('id', id).single();

      print('Raw response for sermon $id: $response');

      return Sermon.fromSupabase(response);
    } catch (e) {
      print('Error fetching sermon by ID: $e');
      return null;
    }
  }

  Future<List<Sermon>> fetchSermons({
    String? series,
    List<String>? topics,
    String? category,
    String? preacher,
    bool? isFavorite,
    int page = 1,
  }) async {
    try {
      var query = _supabase.from('sermons').select();

      if (category != null) {
        query = query.eq('category', category);
      }

      if (series != null) {
        query = query.filter('series_name', 'ilike', series);
      }

      if (preacher != null) {
        query = query.filter('preacher', 'ilike', preacher);
      }

      if (topics != null && topics.isNotEmpty) {
        query = query.filter('tags', 'ov', topics);
      }

      final response = await query
          .order('sermon_date', ascending: false)
          .range((page - 1) * _pageSize, page * _pageSize - 1);

      return response.map((data) => Sermon.fromSupabase(data)).toList();
    } catch (e) {
      print('Error fetching sermons: $e');
      return [];
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response =
          await _supabase.from('sermons').select('category').order('category');
      return (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<String>> fetchPreachers() async {
    try {
      final response =
          await _supabase.from('sermons').select('preacher').order('preacher');
      return (response as List)
          .map((item) => item['preacher'] as String)
          .toSet()
          .toList();
    } catch (e) {
      print('Error fetching preachers: $e');
      return [];
    }
  }

  Future<List<String>> fetchSeries() async {
    try {
      final response = await _supabase
          .from('sermons')
          .select('series_name')
          .not('series_name', 'is', null)
          .order('series_name');
      return (response as List)
          .map((item) => item['series_name'] as String)
          .toSet()
          .toList();
    } catch (e) {
      print('Error fetching series: $e');
      return [];
    }
  }

  Future<List<String>> fetchAllTopics() async {
    try {
      final response = await _supabase.from('sermons').select('topics');
      final allTopics = (response as List)
          .expand((sermon) => (sermon['topics'] as List? ?? []))
          .toSet()
          .toList();
      return allTopics.cast<String>();
    } catch (e) {
      print('Error fetching topics: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String sermonId, bool isFavorite) async {
    try {
      final favoriteIds = await _getFavoriteSermonIds();

      if (isFavorite) {
        favoriteIds.add(sermonId);
      } else {
        favoriteIds.remove(sermonId);
      }

      await _saveFavoriteSermonIds(favoriteIds);
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> toggleDownload(String sermonId, bool isDownloaded,
      String? audioUrl, BuildContext context) async {
    try {
      print('Starting download process for sermon: $sermonId');
      print('Audio URL: $audioUrl');
      print('isDownloaded: $isDownloaded');

      if (audioUrl == null) {
        print('Audio URL is null, showing error message');
        Fluttertoast.showToast(
          msg: 'Audio URL is required for downloading',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }

      final downloads = await _getDownloadedSermons();
      final downloadManager = DownloadManager();

      if (isDownloaded) {
        print('Starting download process...');
        // Start download
        final fileName =
            '${sermonId}_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final localPath = await downloadManager.downloadSermon(
          url: audioUrl,
          fileName: fileName,
          sermonId: sermonId,
          onProgress: (progress) async {
            print('Download progress: $progress%');
          },
        );

        if (localPath == null) {
          print('Download failed: localPath is null');
          Fluttertoast.showToast(
            msg: 'Failed to download sermon',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return false;
        }

        print('Download completed. Saving to local storage...');
        downloads[sermonId] = localPath;

        print('Showing success message');
        Fluttertoast.showToast(
          msg: 'Sermon downloaded successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print('Removing downloaded sermon...');
        final localPath = downloads[sermonId];
        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) {
            print('Deleting file: $localPath');
            await file.delete();
          }
        }
        downloads.remove(sermonId);

        print('Showing removal message');
        Fluttertoast.showToast(
          msg: 'Sermon removed from downloads',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      print('Saving download state...');
      await _saveDownloadedSermons(downloads);
      print('Download process completed successfully');
      return true;
    } catch (e, stackTrace) {
      print('Error toggling download: $e');
      print('Stack trace: $stackTrace');
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<bool> updateProgress(String sermonId, double progress) async {
    try {
      await _supabase.from('user_sermon_data').upsert({
        'user_id': _supabase.auth.currentUser!.id,
        'sermon_id': sermonId,
        'progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserSermonData(String sermonId) async {
    try {
      final response = await _supabase
          .from('user_sermon_data')
          .select()
          .eq('sermon_id', sermonId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();
      return response;
    } catch (e) {
      print('Error fetching user sermon data: $e');
      return null;
    }
  }

  Future<List<Sermon>> searchSermons({
    String? searchQuery,
    String? category,
    List<String>? topics,
    String? preacher,
    int page = 1,
  }) async {
    try {
      var query = _supabase.from('sermons').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (preacher != null && preacher.isNotEmpty) {
        query = query.eq('preacher', preacher);
      }

      if (topics != null && topics.isNotEmpty) {
        query = query.contains('tags', topics);
      }

      final response = await query
          .order('sermon_date', ascending: false)
          .range((page - 1) * _pageSize, page * _pageSize - 1);

      print('Fetched sermons response: $response'); // Debug print

      final List<Sermon> sermons = [];
      final downloadedSermons = await _getDownloadedSermons();
      final favoriteIds = await _getFavoriteSermonIds();

      for (var data in response) {
        try {
          // Add downloaded and favorite status
          data['is_downloaded'] = downloadedSermons.containsKey(data['id']);
          data['local_audio_path'] = downloadedSermons[data['id']];
          data['is_favorite'] = favoriteIds.contains(data['id']);
          
          final sermon = Sermon.fromSupabase(data);
          sermons.add(sermon);
        } catch (e) {
          print('Error parsing sermon: $e');
          continue;
        }
      }

      return sermons;
    } catch (e) {
      print('Error searching sermons: $e');
      return [];
    }
  }

  Future<List<Sermon>> getFavoriteSermons({
    String? searchQuery,
    String? category,
    List<String>? topics,
    String? preacher,
    int page = 1,
  }) async {
    final favoriteIds = await _getFavoriteSermonIds();
    if (favoriteIds.isEmpty) return [];

    try {
      var query = _supabase
          .from('sermons')
          .select()
          .in_('id', favoriteIds.toList());

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (preacher != null && preacher.isNotEmpty) {
        query = query.eq('preacher', preacher);
      }

      if (topics != null && topics.isNotEmpty) {
        query = query.contains('tags', topics);
      }

      final response = await query
          .order('sermon_date', ascending: false)
          .range((page - 1) * _pageSize, page * _pageSize - 1);

      final List<Sermon> sermons = [];
      final downloadedSermons = await _getDownloadedSermons();

      for (var data in response) {
        try {
          data['is_downloaded'] = downloadedSermons.containsKey(data['id']);
          data['local_audio_path'] = downloadedSermons[data['id']];
          data['is_favorite'] = true;
          
          final sermon = Sermon.fromSupabase(data);
          sermons.add(sermon);
        } catch (e) {
          print('Error parsing favorite sermon: $e');
          continue;
        }
      }

      return sermons;
    } catch (e) {
      print('Error fetching favorite sermons: $e');
      return [];
    }
  }

  Future<List<Sermon>> getDownloadedSermons({
    String? searchQuery,
    String? category,
    List<String>? topics,
    String? preacher,
    int page = 1,
  }) async {
    try {
      final downloads = await _getDownloadedSermons();
      if (downloads.isEmpty) return [];

      var query = _supabase
          .from('sermons')
          .select()
          .in_('id', downloads.keys.toList());

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (preacher != null && preacher.isNotEmpty) {
        query = query.eq('preacher', preacher);
      }

      if (topics != null && topics.isNotEmpty) {
        query = query.contains('tags', topics);
      }

      final response = await query
          .order('sermon_date', ascending: false)
          .range((page - 1) * _pageSize, page * _pageSize - 1);

      final List<Sermon> sermons = [];
      for (var data in response) {
        try {
          data['is_downloaded'] = true;
          data['local_audio_path'] = downloads[data['id']];
          data['is_favorite'] = await isSermonFavorite(data['id']);
          
          final sermon = Sermon.fromSupabase(data);
          sermons.add(sermon);
        } catch (e) {
          print('Error parsing downloaded sermon: $e');
          continue;
        }
      }

      return sermons;
    } catch (e) {
      print('Error fetching downloaded sermons: $e');
      return [];
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('sermons')
          .select('category')
          .not('category', 'is', null);

      return (response as List)
          .map((item) => item['category'] as String)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<String>> getAllTopics() async {
    try {
      final response = await _supabase
          .from('sermons')
          .select('tags')
          .not('tags', 'is', null);

      final Set<String> topics = {};
      for (var item in response) {
        if (item['tags'] is List) {
          topics.addAll((item['tags'] as List).cast<String>());
        }
      }
      return topics.toList()..sort();
    } catch (e) {
      print('Error fetching topics: $e');
      return [];
    }
  }

  Future<List<String>> getAllPreachers() async {
    try {
      final response = await _supabase
          .from('sermons')
          .select('preacher')
          .not('preacher', 'is', null);

      return (response as List)
          .map((item) => item['preacher'] as String)
          .where((preacher) => preacher.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      print('Error fetching preachers: $e');
      return [];
    }
  }

  Future<List<Sermon>> getRelatedSermons(String sermonId) async {
    try {
      // First get the current sermon to get its series and tags
      final currentSermon =
          await _supabase.from('sermons').select().eq('id', sermonId).single();

      var query = _supabase.from('sermons').select();

      // Add filters one by one
      query = query.neq('id', sermonId);

      if (currentSermon['series_name'] != null) {
        query = query.eq('series_name', currentSermon['series_name']);
      } else if (currentSermon['tags'] != null &&
          currentSermon['tags'].isNotEmpty) {
        // Use contains for array overlap
        query = query.contains('tags', currentSermon['tags']);
      }

      // Add limit and order after filters
      final response =
          await query.limit(5).order('sermon_date', ascending: false);

      return response.map((data) => Sermon.fromSupabase(data)).toList();
    } catch (e) {
      print('Error fetching related sermons: $e');
      return [];
    }
  }

  Future<List<Sermon>> getSermonsByCategory(String category) async {
    try {
      if (!SermonCategories.all.contains(category)) {
        throw ArgumentError('Invalid category');
      }

      final response = await _supabase
          .from('sermons')
          .select()
          .eq('category', category)
          .order('sermon_date', ascending: false);

      return response.map((data) => Sermon.fromSupabase(data)).toList();
    } catch (e) {
      print('Error fetching sermons by category: $e');
      return [];
    }
  }

  Future<bool> isSermonFavorite(String sermonId) async {
    final favoriteIds = await _getFavoriteSermonIds();
    return favoriteIds.contains(sermonId);
  }

  Future<bool> isSermonDownloaded(String sermonId) async {
    final downloads = await _getDownloadedSermons();
    return downloads.containsKey(sermonId);
  }
}
