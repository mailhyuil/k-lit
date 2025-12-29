import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Supabase 클라이언트 초기화 및 접근
class SupabaseService {
  /// OAuth 리다이렉트 URL
  static const String redirectUrl = 'com.mailhyuil.library://login-callback/';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  /// Supabase 인스턴스 접근
  static Supabase get instance => Supabase.instance;

  /// Supabase 클라이언트 접근
  static GoTrueClient get auth => instance.client.auth;

  /// 현재 사용자
  static User? get currentUser => auth.currentUser;
}
