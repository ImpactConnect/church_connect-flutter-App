import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/devotional.dart';

class SupabaseDevotionalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Devotional> getTodaysDevotional() async {
    final response = await _supabase
        .from('devotionals')
        .select()
        .eq('date', DateTime.now().toIso8601String().split('T')[0])
        .single();
    return Devotional.fromJson(response);
  }

  Future<List<Devotional>> getRecentDevotionals({int limit = 7}) async {
    final response = await _supabase
        .from('devotionals')
        .select()
        .order('date', ascending: false)
        .limit(limit);
    
    return List<Devotional>.from(
      response.map((json) => Devotional.fromJson(json)),
    );
  }

  Future<List<Devotional>> searchDevotionals(String query) async {
    final response = await _supabase
        .from('devotionals')
        .select()
        .textSearch('title', query)
        .order('date', ascending: false);

    return List<Devotional>.from(
      response.map((json) => Devotional.fromJson(json)),
    );
  }

  Future<Devotional> getDevotionalByDate(DateTime date) async {
    final response = await _supabase
        .from('devotionals')
        .select()
        .eq('date', date.toIso8601String().split('T')[0])
        .single();
    return Devotional.fromJson(response);
  }
}
