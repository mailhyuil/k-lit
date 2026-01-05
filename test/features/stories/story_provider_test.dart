import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/core/config/supabase_client.dart';
import 'package:k_lit/features/stories/models/story.dart';
import 'package:k_lit/features/stories/providers/story_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
  });

  group('Story Providers', () {

    final now = DateTime.now();
    final storyMap = {
        'id': 'story-1',
        'story_collections': [{'collection_id': 'collection-1'}],
        'title_ar': 'قصة قصيرة',
        'intro_ar': 'مقدمة القصة',
        'commentary_ar': 'تعليق على القصة',
        'content_url': 'stories/story-1.txt',
        'content_version': 2,
        'content_size_bytes': 10240,
        'order_index': 1,
        'is_free': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
    };

    test('storyProvider returns a story when it exists', () async {
        // ARRANGE
        when(() => mockSupabaseClient.from('stories')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.eq('id', 'story-1')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.single()).thenAnswer((_) async => storyMap);

        final container = ProviderContainer(overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
        ]);

        // ACT
        final storyResult = await container.read(storyProvider('story-1').future);

        // ASSERT
        expect(storyResult, isA<Story>());
        expect(storyResult?.id, 'story-1');
    });

    test('storyProvider returns null when it does not exist', () async {
        // ARRANGE
        when(() => mockSupabaseClient.from('stories')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.eq('id', 'story-nonexistent')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.single()).thenThrow(Exception('Not found'));

        final container = ProviderContainer(overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
        ]);

        // ACT
        final storyResult = await container.read(storyProvider('story-nonexistent').future);

        // ASSERT
        expect(storyResult, isNull);
    });

     test('collectionStoriesProvider returns a list of stories', () async {
        // ARRANGE
        when(() => mockSupabaseClient.from('stories')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.eq('story_collections.collection_id', 'collection-1')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.order('order_index', referencedTable: 'story_collections', ascending: true)).thenAnswer((_) async => [storyMap]);

        final container = ProviderContainer(overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
        ]);

        // ACT
        final storiesResult = await container.read(collectionStoriesProvider('collection-1').future);

        // ASSERT
        expect(storiesResult, isA<List<Story>>());
        expect(storiesResult.length, 1);
        expect(storiesResult.first.id, 'story-1');
    });

  });
}
