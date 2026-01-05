import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/features/collections/providers/collection_provider.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/story_content.dart';
import '../services/story_cache_service.dart';
import '../services/story_storage_service.dart';
import 'story_provider.dart';

/// Story Content 로딩 상태
enum ContentLoadingState { idle, checkingCache, downloading, loaded, error }

/// 콘텐츠 자동 로드 Provider (권한 체크 포함)
final storyContentProvider = FutureProvider.family<StoryContent, String>((
  ref,
  storyId,
) async {
  // Story 메타데이터 가져오기
  final story = await ref.watch(storyByStoryIdProvider(storyId).future);
  if (story == null) {
    throw Exception('Story not found');
  }
  final collection = await ref.watch(
    collectionByIdProvider(story.collections.first.id).future,
  );
  if (collection == null) {
    throw Exception('Collection not found');
  }
  // ⚠️ 권한 체크
  if (!story.isFree) {
    // 유료 작품인 경우 entitlement 확인
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (!isAuthenticated) {
      throw Exception('로그인이 필요합니다.');
    }
    final purchaseState = ref.watch(purchaseControllerProvider);
    if (purchaseState.customerInfo == null) {
      // customerInfo가 로드될 때까지 기다림
      await ref.watch(purchaseControllerProvider.notifier).refresh();
    }
    final isPurchased = ref.watch(
      collectionPurchasedProvider(collection.rcIdentifier ?? ''),
    );
    if (!isPurchased) {
      throw Exception('이 작품을 읽으려면 컬렉션을 구매해야 합니다.');
    }
    debugPrint(
      '✅ Entitlement verified for collection: ${story.collections.first.id}',
    );
  }

  // 1단계: 캐시 확인
  final cacheService = ref.read(storyCacheServiceProvider);
  debugPrint('🔍 Checking cache for: $storyId');
  final cachedContent = await cacheService.getCachedContent(
    storyId,
    story.contentVersion,
  );

  if (cachedContent != null) {
    // 캐시에서 로드 성공
    debugPrint('✅ Content loaded from cache');
    return cachedContent;
  }

  // 2단계: Storage에서 다운로드
  final storageService = ref.read(storyStorageServiceProvider);
  debugPrint('📥 Downloading content from Storage...');
  final content = await storageService.downloadContent(story.contentUrl);

  // 3단계: 캐시에 저장
  await cacheService.saveToCache(storyId, story.contentVersion, content);

  debugPrint('✅ Content loaded and cached');
  return content;
});

/// Cache Service Provider
final storyCacheServiceProvider = Provider<StoryCacheService>((ref) {
  return StoryCacheService();
});

/// Storage Service Provider
final storyStorageServiceProvider = Provider<StoryStorageService>((ref) {
  return StoryStorageService();
});
