import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase 설정을 관리하는 클래스
class SupabaseConfig {
  /// Supabase URL
  static String get url {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      // 개발용: 더미 URL 반환
      return 'https://placeholder.supabase.co';
    }
    return url;
  }

  /// Supabase Anonymous Key
  static String get anonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      // 개발용: 더미 키 반환
      return 'placeholder-key';
    }
    return key;
  }
}
