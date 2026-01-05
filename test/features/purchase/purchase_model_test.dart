// test/features/purchase/purchase_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/purchase/models/purchase.dart';

void main() {
  group('Purchase Model', () {
    final now = DateTime.now();
    final purchaseMap = {
      'id': 'purchase-1',
      'user_id': 'user-1',
      'collection_id': 'collection-1',
      'product_id': 'product-1',
      'transaction_id': 'trans-1',
      'source': 'revenuecat',
      'amount_cents': 999,
      'currency': 'USD',
      'status': 'completed',
      'created_at': now.toIso8601String(),
    };

    test('fromMap creates a valid Purchase object', () {
      final purchase = Purchase.fromMap(purchaseMap);

      expect(purchase.id, 'purchase-1');
      expect(purchase.userId, 'user-1');
      expect(purchase.collectionId, 'collection-1');
      expect(purchase.productId, 'product-1');
      expect(purchase.transactionId, 'trans-1');
      expect(purchase.source, 'revenuecat');
      expect(purchase.amountCents, 999);
      expect(purchase.currency, 'USD');
      expect(purchase.status, 'completed');
      expect(purchase.createdAt.isAtSameMomentAs(now), isTrue);
    });
  });
}
