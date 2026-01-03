import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_client.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../models/collection.dart';

/// 모든 컬렉션 목록을 제공하는 프로바이더 (Supabase)
final collectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final response = await SupabaseService.instance.client
      .from('collections')
      .select('*, stories(count)')
      .order('order_index', ascending: true);
  return (response as List)
      .map((map) => Collection.fromMap(map as Map<String, dynamic>))
      .toList();
});

/// 구매된 컬렉션 목록을 제공하는 프로바이더
final purchasedCollectionsProvider = FutureProvider<List<Collection>>((
  ref,
) async {
  final customerInfo = ref.watch(customerInfoProvider);
  if (customerInfo == null) {
    await ref.watch(purchaseControllerProvider.notifier).refresh();
    return [];
  }
  final collections = await ref.watch(collectionsProvider.future);
  final collectionPurchased = collections.where(
    (collection) => customerInfo.allPurchasedProductIdentifiers.contains(
      collection.rcIdentifier,
    ),
  );
  return collectionPurchased
      .map((collection) => collection.copyWith(isPurchased: true))
      .toList();
});

final collectionsWithStatusProvider = FutureProvider<List<Collection>>((
  ref,
) async {
  final customerInfo = ref.watch(customerInfoProvider);
  final collections = await ref.watch(collectionsProvider.future);
  return collections
      .map(
        (collection) => collection.copyWith(
          isPurchased:
              customerInfo?.allPurchasedProductIdentifiers.contains(
                collection.rcIdentifier,
              ) ??
              false,
        ),
      )
      .toList();
});

/// 특정 컬렉션을 제공하는 프로바이더
final collectionByIdProvider = FutureProvider.family<Collection?, String>((
  ref,
  collectionId,
) async {
  final collections = await ref.watch(collectionsWithStatusProvider.future);
  final collection = collections.where((c) => c.id == collectionId).firstOrNull;
  return collection;
});

/// 무료 컬렉션 목록
final freeCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final collections = await ref.watch(collectionsProvider.future);
  return collections.where((c) => c.isFree).toList();
});

/// 컬렉션 검색 프로바이더
final searchCollectionsProvider =
    FutureProvider.family<List<Collection>, String>((ref, query) async {
      if (query.isEmpty) {
        return ref.watch(collectionsWithStatusProvider.future);
      }

      final collections = await ref.watch(collectionsWithStatusProvider.future);
      final lowerQuery = query.toLowerCase();

      return collections.where((collection) {
        return collection.titleAr.toLowerCase().contains(lowerQuery) ||
            (collection.descriptionAr?.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();
    });
