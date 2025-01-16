import '../config/supabase_config.dart';

class SupabaseEventService {
  final _supabase = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> fetchEvents({
    String? category,
  }) async {
    try {
      print('Fetching events from Supabase...');
      print('Category filter: $category');

      var query = _supabase.from('events').select('''
            id,
            title,
            description,
            start_date,
            end_date,
            location,
            image_url,
            category
          ''');

      // Apply category filter if specified
      if (category != null && category != 'All') {
        print('Applying category filter: $category');
        query = query.eq('category', category);
      }

      // Add ordering
      final data = await query.order('start_date');

      print('Fetched ${data.length} events');

      if (data.isEmpty) {
        print('No events found in the database');
      } else {
        print('First event: ${data.first}');
      }

      return List<Map<String, dynamic>>.from(data);
    } catch (e, stackTrace) {
      print('Error fetching events: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getEventById(int id) async {
    try {
      print('Fetching event with ID: $id');

      final data =
          await _supabase.from('events').select().eq('id', id).single();

      print('Event data: $data');
      return data;
    } catch (e) {
      print('Error fetching event by ID: $e');
      return null;
    }
  }

  Future<void> insertTestEvent() async {
    try {
      print('Inserting test event...');
      await _supabase.from('events').insert({
        'title': 'Test Event',
        'description': 'This is a test event',
        'start_date': DateTime.now().toIso8601String(),
        'end_date':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'location': 'Test Location',
        'category': 'Test',
        'image_url': null
      }).select();
      print('Test event inserted successfully');
    } catch (e, stackTrace) {
      print('Error inserting test event: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
