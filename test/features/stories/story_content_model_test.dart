// test/features/stories/story_content_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/stories/models/story_content.dart';

void main() {
  group('StoryContent Model', () {
    const storyContent = StoryContent(version: 1, bodyAr: 'Hello World');

    test('copyWith creates a modified copy', () {
      final updated = storyContent.copyWith(version: 2);
      expect(updated.version, 2);
      expect(updated.bodyAr, 'Hello World');
    });

    test('equality operator works correctly', () {
      const storyContent1 = StoryContent(version: 1, bodyAr: 'Hello World');
      const storyContent2 = StoryContent(version: 1, bodyAr: 'Hello World');
      const storyContent3 = StoryContent(version: 2, bodyAr: 'Hello World');
      expect(storyContent1 == storyContent2, isTrue);
      expect(storyContent1 == storyContent3, isFalse);
    });
  });

  group('StoryMeta Model', () {
    test('fromJson creates a valid StoryMeta object', () {
      final meta = StoryMeta.fromJson({'version': 2});
      expect(meta.version, 2);
    });

    test('toJson returns a valid JSON map', () {
      const meta = StoryMeta(version: 3);
      final json = meta.toJson();
      expect(json['version'], 3);
    });
     test('fromJsonString creates a valid StoryMeta object', () {
      final meta = StoryMeta.fromJsonString('{"version": 4}');
      expect(meta.version, 4);
    });
    test('toJsonString returns a valid JSON string', () {
      const meta = StoryMeta(version: 5);
      final jsonString = meta.toJsonString();
      expect(jsonString, '{"version":5}');
    });
  });

  group('CachedContentMetadata Model', () {
    final now = DateTime.now();
    final metadataJson = {
      'story_id': 'story-1',
      'version': 1,
      'cached_at': now.toIso8601String(),
      'size_bytes': 1024,
    };

    test('fromJson creates a valid CachedContentMetadata object', () {
      final metadata = CachedContentMetadata.fromJson(metadataJson);
      expect(metadata.storyId, 'story-1');
      expect(metadata.version, 1);
      expect(metadata.cachedAt.isAtSameMomentAs(now), isTrue);
      expect(metadata.sizeBytes, 1024);
    });

    test('toJson returns a valid JSON map', () {
      final metadata = CachedContentMetadata(
        storyId: 'story-1',
        version: 1,
        cachedAt: now,
        sizeBytes: 1024,
      );
      final json = metadata.toJson();
      expect(json['story_id'], 'story-1');
      expect(json['version'], 1);
      expect(json['cached_at'], now.toIso8601String());
      expect(json['size_bytes'], 1024);
    });

    test('isExpired returns correct value', () {
      final notExpired = CachedContentMetadata(
        storyId: 's1',
        version: 1,
        cachedAt: DateTime.now(),
        sizeBytes: 100,
      );
      final expired = CachedContentMetadata(
        storyId: 's2',
        version: 1,
        cachedAt: DateTime.now().subtract(const Duration(days: 31)),
        sizeBytes: 100,
      );
      expect(notExpired.isExpired(), isFalse);
      expect(expired.isExpired(), isTrue);
    });
  });
}
