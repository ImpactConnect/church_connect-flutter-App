import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://eidatvzknqeakkypvemy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpZGF0dnprbnFlYWtreXB2ZW15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5NDQ2NDUsImV4cCI6MjA1MjUyMDY0NX0.tRceTZScglEcHuOzGI2ck7AuEcNapPiM1QSGxsMFMG8';

  static Future<void> initialize() async {
    try {
      print('Initializing Supabase with URL: $supabaseUrl');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );
      print('Supabase initialized successfully');
      
      // Verify connection
      final client = Supabase.instance.client;
      final response = await client.from('events').select('count');
      print('Connection test response: $response');
    } catch (e, stackTrace) {
      print('Error initializing Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
