import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueCatService {
  Future<Offerings> getOfferings() => Purchases.getOfferings();
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();
  Future<PurchaseResult> purchasePackage(Package package) => Purchases.purchasePackage(package);
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();
}

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});
