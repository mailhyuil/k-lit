import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_client.dart';
import '../models/story.dart';

/// 특정 컬렉션의 모든 작품을 제공하는 프로바이더 (Supabase)
final collectionStoriesProvider = FutureProvider.family<List<Story>, String>((
  ref,
  collectionId,
) async {
  final response = await SupabaseService.instance.client
      .from('stories')
      .select()
      .eq('collection_id', collectionId)
      .order('order_index', ascending: true);

  return (response as List)
      .map((map) => Story.fromMap(map as Map<String, dynamic>))
      .toList();
});

/// 특정 작품을 제공하는 프로바이더 (Supabase)
final storyProvider = FutureProvider.family<Story?, String>((
  ref,
  storyId,
) async {
  try {
    final response = await SupabaseService.instance.client
        .from('stories')
        .select()
        .eq('id', storyId)
        .single();

    return Story.fromMap(response);
  } catch (e) {
    // 작품을 찾지 못한 경우 null 반환
    return null;
  }
});

/// 무료 작품 목록을 제공하는 프로바이더 (Supabase)
final freeStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final response = await SupabaseService.instance.client
      .from('stories')
      .select()
      .eq('is_free', true)
      .order('order_index', ascending: true);

  return (response as List)
      .map((map) => Story.fromMap(map as Map<String, dynamic>))
      .toList();
});
