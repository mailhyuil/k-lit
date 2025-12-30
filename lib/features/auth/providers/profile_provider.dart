import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_client.dart';
import '../models/profile.dart';

/// 현재 사용자 프로필 조회
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = SupabaseService.currentUser;
  
  if (user == null) {
    return null;
  }

  try {
    final response = await SupabaseService.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Profile.fromJson(response);
  } catch (e) {
    // 프로필이 없거나 조회 실패 시 null 반환
    return null;
  }
});

