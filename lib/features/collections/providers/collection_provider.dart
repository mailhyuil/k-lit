import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';

import '../../../core/config/supabase_client.dart';
import '../models/collection.dart';

/// 모든 컬렉션 목록을 제공하는 프로바이더 (Supabase)
final collectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final response = await SupabaseService.instance.client
      .from('collections')
      .select('*, stories(count)')
      .order('order_index', ascending: true);
  return (response as List).map((map) => Collection.fromMap(map as Map<String, dynamic>)).toList();
});

/// 구매된 컬렉션 목록을 제공하는 프로바이더
final purchasedCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final collections = await ref.watch(collectionsProvider.future);
  final collectionPurchased = collections.where(
    (collection) => ref.read(collectionPurchasedProvider(collection.rcIdentifier ?? '')),
  );
  return collectionPurchased.toList();
});

final collectionsWithStatusProvider = FutureProvider<List<Collection>>((ref) async {
  final customerInfo = ref.read(customerInfoProvider);
  final collections = await ref.watch(collectionsProvider.future);
  return collections
      .map(
        (collection) => collection.copyWith(
          isPurchased:
              customerInfo?.allPurchasedProductIdentifiers.contains(collection.rcIdentifier) ??
              false,
        ),
      )
      .toList();
});

/// 특정 컬렉션을 제공하는 프로바이더
final collectionProvider = FutureProvider.family<Collection?, String>((ref, collectionId) async {
  final collections = await ref.watch(collectionsProvider.future);
  final collection = collections.where((c) => c.id == collectionId).firstOrNull;
  if (collection == null) return null;
  // 구매 상태 확인
  final isPurchased = ref.read(collectionPurchasedProvider(collection.rcIdentifier ?? ''));
  return collection.copyWith(isPurchased: isPurchased);
});

/// 무료 컬렉션 목록
final freeCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final collections = await ref.watch(collectionsProvider.future);
  return collections.where((c) => c.isFree).toList();
});

/// 컬렉션 검색 프로바이더
final searchCollectionsProvider = FutureProvider.family<List<Collection>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) {
    return ref.watch(purchasedCollectionsProvider.future);
  }

  final collections = await ref.watch(purchasedCollectionsProvider.future);
  final lowerQuery = query.toLowerCase();

  return collections.where((collection) {
    return collection.titleAr.toLowerCase().contains(lowerQuery) ||
        (collection.descriptionAr?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
});
