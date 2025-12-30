import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Purchase 상태
class PurchaseState {
  final bool isLoading;
  final String? error;
  final Offerings? offerings;
  final CustomerInfo? customerInfo;

  const PurchaseState({
    this.isLoading = false,
    this.error,
    this.offerings,
    this.customerInfo,
  });

  PurchaseState copyWith({
    bool? isLoading,
    String? error,
    Offerings? offerings,
    CustomerInfo? customerInfo,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      offerings: offerings ?? this.offerings,
      customerInfo: customerInfo ?? this.customerInfo,
    );
  }
}

/// Purchase Controller
class PurchaseController extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    // 초기화 후 데이터 로드
    Future.microtask(() {
      _loadOfferings();
      _loadCustomerInfo();
    });
    return const PurchaseState();
  }

  /// Offerings 불러오기 (상품 목록)
  Future<void> _loadOfferings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final offerings = await Purchases.getOfferings();
      state = state.copyWith(isLoading: false, offerings: offerings);
      debugPrint('✅ Offerings 로드 완료: ${offerings.all.length}개');
    } catch (e) {
      debugPrint('❌ Offerings 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Offerings를 불러오는데 실패했습니다',
      );
    }
  }

  /// Customer Info 불러오기 (구매 정보)
  Future<void> _loadCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      state = state.copyWith(customerInfo: customerInfo);
      debugPrint('✅ Customer Info 로드 완료');
    } catch (e) {
      debugPrint('❌ Customer Info 로드 실패: $e');
    }
  }

  /// 상품 구매
  Future<bool> purchase(Package package) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      debugPrint('🛒 구매 시작: ${package.storeProduct.identifier}');
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      final customerInfo = purchaseResult.customerInfo;

      state = state.copyWith(isLoading: false, customerInfo: customerInfo);

      debugPrint('✅ 구매 완료!');
      return true;
    } catch (e) {
      String errorMessage = '구매에 실패했습니다';

      if (e.toString().contains('purchaseCancelled')) {
        errorMessage = '구매가 취소되었습니다';
        debugPrint('ℹ️ 사용자가 구매를 취소했습니다');
      } else if (e.toString().contains('productAlreadyPurchased')) {
        errorMessage = '이미 구매한 상품입니다';
        debugPrint('ℹ️ 이미 구매한 상품입니다');
      } else {
        debugPrint('❌ 구매 실패: $e');
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  /// 구매 복원
  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      debugPrint('🔄 구매 복원 시작');

      final customerInfo = await Purchases.restorePurchases();

      state = state.copyWith(isLoading: false, customerInfo: customerInfo);

      debugPrint('✅ 구매 복원 완료');
      return true;
    } catch (e) {
      debugPrint('❌ 구매 복원 실패: $e');
      state = state.copyWith(isLoading: false, error: '구매 복원에 실패했습니다');
      return false;
    }
  }

  /// 특정 컬렉션에 대한 entitlement 확인
  bool hasEntitlement(String collectionId) {
    final customerInfo = state.customerInfo;
    if (customerInfo == null) return false;

    // RevenueCat의 entitlement identifier를 사용
    // 예: "collection_<collectionId>"
    final entitlementId = 'collection_$collectionId';
    final entitlement = customerInfo.entitlements.all[entitlementId];

    return entitlement != null && entitlement.isActive;
  }

  /// 새로고침
  Future<void> refresh() async {
    await Future.wait([_loadOfferings(), _loadCustomerInfo()]);
  }
}

/// Purchase Controller Provider
final purchaseControllerProvider =
    NotifierProvider<PurchaseController, PurchaseState>(PurchaseController.new);

/// 현재 사용 가능한 Offerings Provider
final currentOfferingsProvider = Provider<Offerings?>((ref) {
  return ref.watch(purchaseControllerProvider).offerings;
});

/// Customer Info Provider
final customerInfoProvider = Provider<CustomerInfo?>((ref) {
  return ref.watch(purchaseControllerProvider).customerInfo;
});

/// 특정 컬렉션 구매 여부 Provider
final collectionPurchasedProvider = Provider.family<bool, String>((
  ref,
  collectionId,
) {
  final controller = ref.watch(purchaseControllerProvider.notifier);
  return controller.hasEntitlement(collectionId);
});
