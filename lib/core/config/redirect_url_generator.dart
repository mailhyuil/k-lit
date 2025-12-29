import 'redirect_url_helper.dart';
import 'supabase_config.dart';

/// 현재 Supabase 설정을 기반으로 리다이렉트 URL 생성
class RedirectUrlGenerator {
  /// Flutter 앱용 리다이렉트 URL
  /// 커스텀 URL: com.mailhyuil.library://login-callback/
  static String get flutterRedirectUrl {
    return RedirectUrlHelper.generateFlutterRedirectUrl();
  }

  /// Google Cloud Console용 리다이렉트 URL
  static String? get googleRedirectUrl {
    final url = SupabaseConfig.url;
    if (url.contains('placeholder')) {
      return null;
    }
    return RedirectUrlHelper.generateGoogleRedirectUrl(url);
  }

  /// 프로젝트 참조 ID
  static String? get projectRef {
    final url = SupabaseConfig.url;
    if (url.contains('placeholder')) {
      return null;
    }
    return RedirectUrlHelper.extractProjectRef(url);
  }

  /// 모든 리다이렉트 URL 정보 출력 (디버깅용)
  static void printRedirectUrls() {
    final url = SupabaseConfig.url;
    final projectRef = url.contains('placeholder')
        ? null
        : RedirectUrlHelper.extractProjectRef(url);
    final flutterUrl = flutterRedirectUrl;
    final googleUrl = googleRedirectUrl;

    print('\n📋 OAuth 리다이렉트 URL 정보');
    print('─' * 50);
    if (projectRef != null) {
      print('프로젝트 참조 ID: $projectRef');
    }
    print('\n1️⃣  Flutter 앱 리다이렉트 URL:');
    print('   $flutterUrl');
    if (googleUrl != null) {
      print('\n2️⃣  Google Cloud Console에 추가할 URL:');
      print('   $googleUrl');
    }
    print('─' * 50);
  }
}
