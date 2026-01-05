// test/features/stories/story_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/stories/models/story.dart';

void main() {
  group('Story Model', () {
    final now = DateTime.now();
    final storyMap = {
      'id': 'story-1',
      'story_collections': [
        {'collection_id': 'collection-1'}
      ],
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

    test('fromMap creates a valid Story object', () {
      final story = Story.fromMap(storyMap);

      expect(story.id, 'story-1');
      expect(story.collectionId, 'collection-1');
      expect(story.titleAr, 'قصة قصيرة');
      expect(story.introAr, 'مقدمة القصة');
      expect(story.commentaryAr, 'تعليق على القصة');
      expect(story.contentUrl, 'stories/story-1.txt');
      expect(story.contentVersion, 2);
      expect(story.contentSizeBytes, 10240);
      expect(story.orderIndex, 1);
      expect(story.isFree, false);
      expect(story.createdAt.isAtSameMomentAs(now), isTrue);
      expect(story.updatedAt.isAtSameMomentAs(now), isTrue);
    });

    test('fromMap handles null and default values', () {
        final minimalStoryMap = {
            'id': 'story-2',
            'story_collections': [
                {'collection_id': 'collection-2'}
            ],
            'title_ar': 'قصة أخرى',
            'content_url': 'stories/story-2.txt',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
        };
        final story = Story.fromMap(minimalStoryMap);
        expect(story.introAr, isNull);
        expect(story.commentaryAr, isNull);
        expect(story.contentVersion, 1);
        expect(story.contentSizeBytes, isNull);
        expect(story.orderIndex, 0);
        expect(story.isFree, false);
    });


    test('copyWith creates a modified copy', () {
      final original = Story.fromMap(storyMap);
      final updated = original.copyWith(isFree: true, titleAr: 'Updated Story');

      expect(updated.id, original.id);
      expect(updated.titleAr, 'Updated Story');
      expect(updated.isFree, true);
      expect(updated.contentVersion, original.contentVersion);
    });

    test('getFullContent combines text parts correctly', () {
      final story = Story.fromMap(storyMap);
      const body = 'This is the main body of the story.';
      final fullContent = story.getFullContent(body);

      expect(fullContent, 'مقدمة القصة\n\n$body\n\nتعليق على القصة');
    });

     test('getFullContent handles null intro/commentary', () {
      final story = Story.fromMap(storyMap).copyWith(introAr: null, commentaryAr: null);
      const body = 'Main body only.';
      final fullContent = story.getFullContent(body);

      expect(fullContent, body);
    });
  });
}
