/// OAuth 리다이렉트 URL 생성 유틸리티
class RedirectUrlHelper {
  /// Supabase URL에서 프로젝트 참조 ID 추출
  static String? extractProjectRef(String supabaseUrl) {
    try {
      // URL 형식: https://{project-ref}.supabase.co
      final uri = Uri.parse(supabaseUrl);
      final host = uri.host;

      // .supabase.co로 끝나는지 확인
      if (host.endsWith('.supabase.co')) {
        // 프로젝트 참조 ID 추출
        final projectRef = host.replaceAll('.supabase.co', '');
        return projectRef;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Flutter 앱용 리다이렉트 URL 생성
  /// 커스텀 URL: com.mailhyuil.library://login-callback/
  static String generateFlutterRedirectUrl([String? supabaseUrl]) {
    return 'com.mailhyuil.library://login-callback/';
  }

  /// Google Cloud Console용 리다이렉트 URL 생성
  /// 형식: https://{project-ref}.supabase.co/auth/v1/callback
  static String? generateGoogleRedirectUrl(String supabaseUrl) {
    final projectRef = extractProjectRef(supabaseUrl);
    if (projectRef == null) return null;

    return 'https://$projectRef.supabase.co/auth/v1/callback';
  }

  /// 모든 리다이렉트 URL 생성
  static Map<String, String?> generateAllRedirectUrls(String supabaseUrl) {
    return {
      'flutter': generateFlutterRedirectUrl(supabaseUrl),
      'google': generateGoogleRedirectUrl(supabaseUrl),
      'projectRef': extractProjectRef(supabaseUrl),
    };
  }
}
