// test/features/auth/profile_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/auth/models/profile.dart';

void main() {
  group('Profile Model', () {
    final now = DateTime.now();
    final profileJson = {
      'id': 'user-id-123',
      'username': 'testuser',
      'avatar_url': 'http://example.com/avatar.png',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson creates a valid Profile object', () {
      final profile = Profile.fromMap(profileJson);

      expect(profile.id, 'user-id-123');
      expect(profile.username, 'testuser');
      expect(profile.avatarUrl, 'http://example.com/avatar.png');
      // Using isAtSameMomentAs to compare DateTimes
      expect(profile.createdAt.isAtSameMomentAs(now), isTrue);
      expect(profile.updatedAt.isAtSameMomentAs(now), isTrue);
    });

    test('toJson returns a valid JSON map', () {
      final profile = Profile(
        id: 'user-id-123',
        username: 'testuser',
        avatarUrl: 'http://example.com/avatar.png',
        createdAt: now,
        updatedAt: now,
      );

      final json = profile.toJson();

      expect(json['id'], 'user-id-123');
      expect(json['username'], 'testuser');
      expect(json['avatar_url'], 'http://example.com/avatar.png');
      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('fromJson handles null values', () {
      final profileJsonWithNulls = {
        'id': 'user-id-456',
        'username': null,
        'avatar_url': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final profile = Profile.fromMap(profileJsonWithNulls);

      expect(profile.id, 'user-id-456');
      expect(profile.username, isNull);
      expect(profile.avatarUrl, isNull);
    });

    test('toJson handles null values', () {
      final profileWithNulls = Profile(
        id: 'user-id-456',
        createdAt: now,
        updatedAt: now,
      );

      final json = profileWithNulls.toJson();
      expect(json['username'], isNull);
      expect(json['avatar_url'], isNull);
    });
  });
}
