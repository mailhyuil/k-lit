import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late final SupabaseClient instance;
  static late final GoTrueClient auth;
  static late final String? redirectUrl;

  static User? get currentUser => auth.currentUser;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      debug: kDebugMode,
    );
    instance = Supabase.instance.client;
    auth = instance.auth;
    redirectUrl = (kIsWeb) ? null : dotenv.env['SUPABASE_REDIRECT_URL'];
  }
}

/// Provider for the Supabase client for dependency injection.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.instance;
});