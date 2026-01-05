import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';
import 'package:k_lit/features/purchase/services/revenuecat_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Mocks
class MockRevenueCatService extends Mock implements RevenueCatService {}
class MockOfferings extends Mock implements Offerings {}
class MockCustomerInfo extends Mock implements CustomerInfo {}
class MockPackage extends Mock implements Package {}
class MockStoreProduct extends Mock implements StoreProduct {}
class MockPurchaseResult extends Mock implements PurchaseResult {}

void main() {
  late MockRevenueCatService mockRevenueCatService;
  late ProviderContainer container;

  setUp(() {
    mockRevenueCatService = MockRevenueCatService();
    container = ProviderContainer(
      overrides: [
        revenueCatServiceProvider.overrideWithValue(mockRevenueCatService),
      ],
    );
     // Mock the initial load
    when(() => mockRevenueCatService.getOfferings()).thenAnswer((_) async => MockOfferings());
    when(() => mockRevenueCatService.getCustomerInfo()).thenAnswer((_) async => MockCustomerInfo());
  });

  group('PurchaseController', () {
    test('initial state is correct', () {
      final state = container.read(purchaseControllerProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      // These will be loaded by the microtask in the build method.
      // So we can't easily test the pre-load state without more complex setup.
    });

    test('_loadOfferings success', () async {
      // ARRANGE
      final offerings = MockOfferings();
      when(() => mockRevenueCatService.getOfferings()).thenAnswer((_) async => offerings);

      // ACT
      await container.read(purchaseControllerProvider.notifier).refresh();

      // ASSERT
      final state = container.read(purchaseControllerProvider);
      expect(state.offerings, offerings);
      expect(state.isLoading, isFalse);
    });

    test('_loadCustomerInfo success', () async {
        // ARRANGE
        final customerInfo = MockCustomerInfo();
        when(() => mockRevenueCatService.getCustomerInfo()).thenAnswer((_) async => customerInfo);
        when(() => mockRevenueCatService.restorePurchases()).thenAnswer((_) async => customerInfo);


        // ACT
        await container.read(purchaseControllerProvider.notifier).refresh();

        // ASSERT
        final state = container.read(purchaseControllerProvider);
        expect(state.customerInfo, customerInfo);
    });

    test('purchase success', () async {
        // ARRANGE
        final package = MockPackage();
        final product = MockStoreProduct();
        when(() => package.storeProduct).thenReturn(product);
        when(() => product.identifier).thenReturn('prod_1');

        final purchaseResult = MockPurchaseResult();
        final customerInfo = MockCustomerInfo();
        when(() => purchaseResult.customerInfo).thenReturn(customerInfo);
        when(() => mockRevenueCatService.purchasePackage(package)).thenAnswer((_) async => purchaseResult);

        // ACT
        final success = await container.read(purchaseControllerProvider.notifier).purchase(package);

        // ASSERT
        expect(success, isTrue);
        final state = container.read(purchaseControllerProvider);
        expect(state.customerInfo, customerInfo);
        expect(state.isLoading, isFalse);
    });

     test('purchase cancelled', () async {
        // ARRANGE
        final package = MockPackage();
        final product = MockStoreProduct();
        when(() => package.storeProduct).thenReturn(product);
        when(() => product.identifier).thenReturn('prod_1');

        when(() => mockRevenueCatService.purchasePackage(package)).thenThrow(Exception('purchaseCancelled'));

        // ACT
        final success = await container.read(purchaseControllerProvider.notifier).purchase(package);

        // ASSERT
        expect(success, isFalse);
        final state = container.read(purchaseControllerProvider);
        expect(state.error, '구매가 취소되었습니다');
        expect(state.isLoading, isFalse);
    });

  });
}
