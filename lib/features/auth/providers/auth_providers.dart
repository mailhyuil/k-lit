import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';

/// 인증 상태를 제공하는 스트림 프로바이더
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseService.auth.onAuthStateChange.map((data) => data.session?.user);
});

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 인증 상태 프로바이더 (authenticated/unauthenticated)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

