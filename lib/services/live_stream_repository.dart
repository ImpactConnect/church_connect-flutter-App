import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/live_stream.dart';

class LiveStreamRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'live_streams';

  LiveStreamRepository(this._supabase);

  Future<List<LiveStream>> getUpcomingStreams() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .in_('status', ['scheduled', 'live'])
        .gt('scheduled_start', DateTime.now().toIso8601String())
        .order('scheduled_start')
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return (response.data as List)
        .map((json) => LiveStream.fromJson(json))
        .toList();
  }

  Future<LiveStream?> getCurrentLiveStream() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('status', 'live')
        .order('actual_start', ascending: false)
        .limit(1)
        .single()
        .execute();

    if (response.error != null) {
      if (response.error!.message.contains('Row not found')) {
        return null;
      }
      throw response.error!;
    }

    return LiveStream.fromJson(response.data);
  }

  Future<void> createStream(LiveStream stream) async {
    final response = await _supabase
        .from(_tableName)
        .insert(stream.toJson())
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> updateStream(LiveStream stream) async {
    final response = await _supabase
        .from(_tableName)
        .update(stream.toJson())
        .eq('id', stream.id)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> updateStreamStatus(int id, StreamStatus status) async {
    final response = await _supabase
        .from(_tableName)
        .update({
          'status': status.toString().split('.').last,
          if (status == StreamStatus.live) 'actual_start': DateTime.now().toIso8601String(),
          if (status == StreamStatus.ended) 'actual_end': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> updateViewerCount(int id, int viewerCount) async {
    final response = await _supabase
        .from(_tableName)
        .update({'viewer_count': viewerCount})
        .eq('id', id)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> deleteStream(int id) async {
    final response = await _supabase
        .from(_tableName)
        .delete()
        .eq('id', id)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }
}
