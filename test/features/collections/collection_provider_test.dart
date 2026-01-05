import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/core/config/supabase_client.dart';
import 'package:k_lit/features/collections/models/collection.dart';
import 'package:k_lit/features/collections/providers/collection_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../helpers/mocks.dart';

class MockCustomerInfo extends Mock implements CustomerInfo {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockCustomerInfo mockCustomerInfo;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockCustomerInfo = MockCustomerInfo();
  });

  test('collectionsProvider fetches and returns a list of collections', () async {
    // ARRANGE
    final now = DateTime.now();
    final collectionsData = [
      {
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
        'stories': [{'count': 5}],
      },
    ];

    when(() => mockSupabaseClient.from('collections')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select('*, stories(count)')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.order('order_index', ascending: true)).thenAnswer((_) async => collectionsData);

    final container = ProviderContainer(
      overrides: [
        supabaseClientProvider.overrideWithValue(mockSupabaseClient),
      ],
    );

    // ACT
    final collectionsResult = await container.read(collectionsProvider.future);

    // ASSERT
    expect(collectionsResult, isA<List<Collection>>());
    expect(collectionsResult.length, 1);
    expect(collectionsResult.first.id, 'collection-1');
    expect(collectionsResult.first.storyCount, 5);
  });
}
