import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../models/entitlement.dart';

/// 현재 사용자의 모든 권한을 제공하는 프로바이더 (RevenueCat 기반)
final userEntitlementsProvider = FutureProvider<List<Entitlement>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (!isAuthenticated || currentUser == null) {
    return []; // 로그인하지 않은 경우 빈 목록
  }

  try {
    // RevenueCat CustomerInfo에서 entitlements 가져오기
    final customerInfo = ref.watch(customerInfoProvider);
    
    if (customerInfo == null) {
      return [];
    }

    // RevenueCat entitlements를 Entitlement 모델로 변환
    final entitlements = <Entitlement>[];
    
    for (final entry in customerInfo.entitlements.all.entries) {
      final entitlementInfo = entry.value;
      
      // Entitlement identifier가 "collection_<id>" 형식이라고 가정
      final identifier = entry.key;
      if (!identifier.startsWith('collection_')) continue;
      
      final collectionId = identifier.replaceFirst('collection_', '');
      
      // originalPurchaseDate와 expirationDate 처리
      final DateTime createdDate = DateTime.now(); // 기본값 사용
      DateTime? expirationDate;
      
      // expirationDate가 String?이므로 파싱
      try {
        final expDateStr = entitlementInfo.expirationDate;
        if (expDateStr != null) {
          expirationDate = DateTime.parse(expDateStr);
        }
      } catch (e) {
        debugPrint('Failed to parse expiration date: $e');
      }
      
      entitlements.add(Entitlement(
        id: entitlementInfo.identifier,
        userId: currentUser.id,
        collectionId: collectionId,
        source: 'revenuecat',
        productId: entitlementInfo.productIdentifier,
        createdAt: createdDate,
        expiresAt: expirationDate,
      ));
    }

    return entitlements;
  } catch (e) {
    debugPrint('Error fetching entitlements: $e');
    return [];
  }
});

/// 특정 컬렉션에 대한 권한 확인
final hasEntitlementProvider =
    FutureProvider.family<bool, String>((ref, collectionId) async {
  final entitlements = await ref.watch(userEntitlementsProvider.future);
  return entitlements.any((e) => e.collectionId == collectionId && e.isActive);
});

/// 활성 권한 목록 (만료되지 않은 권한만)
final activeEntitlementsProvider = FutureProvider<List<Entitlement>>((ref) async {
  final entitlements = await ref.watch(userEntitlementsProvider.future);
  return entitlements.where((e) => e.isActive).toList();
});

/// 곧 만료될 권한 목록 (7일 이내)
final expiringEntitlementsProvider = FutureProvider<List<Entitlement>>((ref) async {
  final entitlements = await ref.watch(userEntitlementsProvider.future);
  return entitlements.where((e) {
    if (!e.isActive) return false;
    final days = e.daysUntilExpiration;
    return days != null && days <= 7;
  }).toList();
});

/// Entitlement 관리 컨트롤러
class EntitlementController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Mock 구매 (개발용)
  /// 실제로는 RevenueCat → Edge Function → Entitlements 흐름
  Future<bool> mockPurchase(String collectionId) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      // TODO: 실제 구매 흐름
      // 1. RevenueCat SDK로 구매 요청
      // 2. RevenueCat → Webhook → Edge Function
      // 3. Edge Function이 entitlements 테이블 업데이트
      
      // Mock: 직접 Supabase에 entitlements 추가 (개발용만)
      // 실제로는 Edge Function에서만 가능 (RLS로 차단됨)
      await Future.delayed(const Duration(seconds: 1));

      // Provider 새로고침
      ref.invalidate(userEntitlementsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      debugPrint('Purchase error: $e');
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();

    try {
      // TODO: Edge Function 호출
      // POST /functions/v1/restore_purchases
      
      await Future.delayed(const Duration(seconds: 1));

      // Provider 새로고침
      ref.invalidate(userEntitlementsProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Restore error: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}

final entitlementControllerProvider =
    NotifierProvider<EntitlementController, AsyncValue<void>>(
  () => EntitlementController(),
);

