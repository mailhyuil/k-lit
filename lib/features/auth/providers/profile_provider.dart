import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_client.dart';
import '../models/profile.dart';
import 'auth_providers.dart';

/// 현재 사용자 프로필 조회
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return null;
  }

  final client = ref.watch(supabaseClientProvider);

  try {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Profile.fromMap(response);
  } catch (e) {
    // 프로필이 없거나 조회 실패 시 null 반환
    return null;
  }
});
