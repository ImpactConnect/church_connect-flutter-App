import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<app_models.User?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return app_models.User.fromJson(response);
  }

  Future<void> signUp({
    required String username,
    required String fullName,
    required String gender,
    required String password,
  }) async {
    // Create auth user
    final authResponse = await _supabase.auth.signUp(
      email: '$username@church.app', // Using username as email
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create user');
    }

    // Create user profile
    await _supabase.from('users').insert({
      'id': authResponse.user!.id,
      'username': username,
      'full_name': fullName,
      'gender': gender,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: '$username@church.app',
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
