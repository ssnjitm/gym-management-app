import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets/supabase_secrets.dart';


class SupabaseClientWrapper {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseSecrets.projectUrl,
      anonKey: SupabaseSecrets.anonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Authentication failed: ${e.toString()}');
    }
  }
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static String? get accessToken => client.auth.currentSession?.accessToken;
}