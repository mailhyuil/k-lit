#!/usr/bin/env dart

import 'dart:io';

/// 리다이렉트 URL 생성 스크립트
///
/// 사용법:
///   dart scripts/generate_redirect_urls.dart <supabase-url>
///
/// 예시:
///   dart scripts/generate_redirect_urls.dart https://abcdefghijklmnop.supabase.co

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ 사용법: dart scripts/generate_redirect_urls.dart <supabase-url>');
    print('\n예시:');
    print(
      '  dart scripts/generate_redirect_urls.dart https://abcdefghijklmnop.supabase.co',
    );
    exit(1);
  }

  final supabaseUrl = args[0];

  // URL 형식 검증
  if (!supabaseUrl.contains('.supabase.co')) {
    print('❌ 올바른 Supabase URL 형식이 아닙니다.');
    print('   형식: https://{project-ref}.supabase.co');
    exit(1);
  }

  // 프로젝트 참조 ID 추출
  String? projectRef;
  try {
    final uri = Uri.parse(supabaseUrl);
    final host = uri.host;
    if (host.endsWith('.supabase.co')) {
      projectRef = host.replaceAll('.supabase.co', '');
    }
  } catch (e) {
    print('❌ URL 파싱 오류: $e');
    exit(1);
  }

  if (projectRef == null || projectRef.isEmpty) {
    print('❌ 프로젝트 참조 ID를 추출할 수 없습니다.');
    exit(1);
  }

  // 리다이렉트 URL 생성
  final flutterUrl = 'com.supabase.$projectRef://';
  final googleUrl = 'https://$projectRef.supabase.co/auth/v1/callback';

  // 출력
  print('\n✅ OAuth 리다이렉트 URL 생성 완료\n');
  print('─' * 60);
  print('📋 프로젝트 정보');
  print('─' * 60);
  print('Supabase URL:     $supabaseUrl');
  print('프로젝트 참조 ID:  $projectRef');
  print('\n─' * 60);
  print('🔗 리다이렉트 URL');
  print('─' * 60);
  print('\n1️⃣  Supabase 대시보드 > Authentication > URL Configuration');
  print('   Redirect URLs에 다음을 추가:');
  print('   ┌─────────────────────────────────────────────┐');
  print('   │ $flutterUrl │');
  print('   └─────────────────────────────────────────────┘');
  print('\n2️⃣  Google Cloud Console > APIs & Services > Credentials');
  print('   OAuth 2.0 Client ID > Authorized redirect URIs에 다음을 추가:');
  print('   ┌──────────────────────────────────────────────────────────────┐');
  print('   │ $googleUrl │');
  print('   └──────────────────────────────────────────────────────────────┘');
  print('\n─' * 60);
  print('💡 팁: 위 URL들을 복사하여 각각의 설정 페이지에 추가하세요.');
  print('─' * 60);
}
