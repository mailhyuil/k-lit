// test/features/collections/collection_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/collections/models/collection.dart';

void main() {
  group('Collection Model', () {
    final now = DateTime.now();
    final collectionMap = {
      'id': 'collection-1',
      'title_ar': 'عنوان عربي',
      'description_ar': 'وصف عربي',
      'cover_url': 'covers/collection-1.png',
      'price': 10.0,
      'is_free': false,
      'order_index': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'rc_identifier': 'monthly_10',
      'stories': [
        {'count': 5}
      ],
    };

    test('fromMap creates a valid Collection object', () {
      final collection = Collection.fromMap(collectionMap);

      expect(collection.id, 'collection-1');
      expect(collection.titleAr, 'عنوان عربي');
      expect(collection.descriptionAr, 'وصف عربي');
      expect(collection.coverPath, 'covers/collection-1.png');
      expect(collection.price, 10.0);
      expect(collection.isFree, false);
      expect(collection.orderIndex, 1);
      expect(collection.createdAt.isAtSameMomentAs(now), isTrue);
      expect(collection.updatedAt.isAtSameMomentAs(now), isTrue);
      expect(collection.rcIdentifier, 'monthly_10');
      expect(collection.storyCount, 5);
      // Default values
      expect(collection.isPurchased, false);
    });

    test('fromMap handles null and default values', () {
      final minimalMap = {
        'id': 'collection-2',
        'title_ar': 'عنوان آخر',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final collection = Collection.fromMap(minimalMap);

      expect(collection.id, 'collection-2');
      expect(collection.titleAr, 'عنوان آخر');
      expect(collection.descriptionAr, isNull);
      expect(collection.coverPath, isNull);
      expect(collection.price, 0);
      expect(collection.isFree, false);
      expect(collection.orderIndex, 0);
      expect(collection.rcIdentifier, isNull);
      expect(collection.storyCount, 0);
    });

    test('copyWith creates a modified copy', () {
      final original = Collection.fromMap(collectionMap);
      final updated = original.copyWith(
        isPurchased: true,
        titleAr: 'Updated Title',
      );

      expect(updated.id, original.id);
      expect(updated.titleAr, 'Updated Title');
      expect(updated.isPurchased, true);
      expect(updated.price, original.price);
    });

    test('equality operator works correctly', () {
      final collection1 = Collection.fromMap(collectionMap);
      final collection2 = Collection.fromMap(collectionMap);
      final collection3 =
          collection1.copyWith(id: 'different-id');

      expect(collection1 == collection2, isTrue);
      expect(collection1 == collection3, isFalse);
      expect(collection1.hashCode == collection2.hashCode, isTrue);
      expect(collection1.hashCode == collection3.hashCode, isFalse);
    });
  });
}
