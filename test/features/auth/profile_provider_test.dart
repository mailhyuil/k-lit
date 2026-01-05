import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/core/config/supabase_client.dart';
import 'package:k_lit/features/auth/models/profile.dart';
import 'package:k_lit/features/auth/providers/auth_providers.dart';
import 'package:k_lit/features/auth/providers/profile_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late User user;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    user = FakeUser();
    when(() => user.id).thenReturn('user-id-123');
  });

  test('profileProvider returns profile when user is authenticated and profile exists', () async {
    // ARRANGE
    final now = DateTime.now();
    final profileData = {
      'id': 'user-id-123',
      'username': 'testuser',
      'avatar_url': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.eq('id', 'user-id-123')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.maybeSingle()).thenAnswer((_) async => profileData);

    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWithValue(user),
        supabaseClientProvider.overrideWithValue(mockSupabaseClient),
      ],
    );

    // ACT
    final profileResult = await container.read(profileProvider.future);

    // ASSERT
    expect(profileResult, isA<Profile>());
    expect(profileResult?.id, 'user-id-123');
    expect(profileResult?.username, 'testuser');
  });

  test('profileProvider returns null when user is not authenticated', () async {
    // ARRANGE
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWithValue(null),
      ],
    );

    // ACT
    final profileResult = await container.read(profileProvider.future);

    // ASSERT
    expect(profileResult, isNull);
  });

  test('profileProvider returns null when profile does not exist', () async {
    // ARRANGE
    when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.eq('id', 'user-id-123')).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.maybeSingle()).thenAnswer((_) async => null);

    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWithValue(user),
        supabaseClientProvider.overrideWithValue(mockSupabaseClient),
      ],
    );

    // ACT
    final profileResult = await container.read(profileProvider.future);

    // ASSERT
    expect(profileResult, isNull);
  });
}
