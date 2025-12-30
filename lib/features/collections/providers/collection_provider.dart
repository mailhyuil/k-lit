import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_client.dart';
import '../../auth/providers/auth_providers.dart';
import '../../entitlements/providers/entitlement_provider.dart';
import '../models/collection.dart';

/// 모든 컬렉션 목록을 제공하는 프로바이더 (Supabase)
final collectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final response = await SupabaseService.instance.client
      .from('collections')
      .select('*, stories(count)')
      .order('order_index', ascending: true);
  print('collections: $response');
  return (response as List)
      .map((map) => Collection.fromMap(map as Map<String, dynamic>))
      .toList();
});

/// 구매 상태가 포함된 컬렉션 목록을 제공하는 프로바이더
final collectionsWithPurchaseStatusProvider = FutureProvider<List<Collection>>((
  ref,
) async {
  final collections = await ref.watch(collectionsProvider.future);
  final entitlements = await ref.watch(userEntitlementsProvider.future);

  // Entitlement가 있는 컬렉션 ID 목록
  final purchasedCollectionIds = entitlements
      .map((e) => e.collectionId)
      .toSet();

  return collections.map((collection) {
    return collection.copyWith(
      isPurchased:
          collection.isFree || purchasedCollectionIds.contains(collection.id),
    );
  }).toList();
});

/// 특정 컬렉션을 제공하는 프로바이더
final collectionProvider = FutureProvider.family<Collection?, String>((
  ref,
  collectionId,
) async {
  final collections = await ref.watch(collectionsProvider.future);
  final collection = collections.where((c) => c.id == collectionId).firstOrNull;

  if (collection == null) return null;

  // 구매 상태 확인
  final entitlements = await ref.watch(userEntitlementsProvider.future);
  final isPurchased =
      collection.isFree ||
      entitlements.any((e) => e.collectionId == collectionId && e.isActive);

  return collection.copyWith(isPurchased: isPurchased);
});

/// 무료 컬렉션 목록
final freeCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final collections = await ref.watch(collectionsProvider.future);
  return collections.where((c) => c.isFree).toList();
});

/// 사용자가 구매한 컬렉션 목록
final purchasedCollectionsProvider = FutureProvider<List<Collection>>((
  ref,
) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return [];

  final collections = await ref.watch(collectionsProvider.future);
  final entitlements = await ref.watch(userEntitlementsProvider.future);

  final purchasedCollectionIds = entitlements
      .where((e) => e.isActive)
      .map((e) => e.collectionId)
      .toSet();

  return collections
      .where((c) => c.isFree || purchasedCollectionIds.contains(c.id))
      .map((c) => c.copyWith(isPurchased: true))
      .toList();
});

/// 컬렉션 검색 프로바이더
final searchCollectionsProvider =
    FutureProvider.family<List<Collection>, String>((ref, query) async {
      if (query.isEmpty) {
        return ref.watch(collectionsWithPurchaseStatusProvider.future);
      }

      final collections = await ref.watch(
        collectionsWithPurchaseStatusProvider.future,
      );
      final lowerQuery = query.toLowerCase();

      return collections.where((collection) {
        return collection.titleAr.toLowerCase().contains(lowerQuery) ||
            (collection.descriptionAr?.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();
    });
