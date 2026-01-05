// test/features/auth/auth_providers_test.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_lit/features/auth/providers/auth_providers.dart';
import 'package:k_lit/core/config/supabase_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockGoTrueClient mockGoTrueClient;
  late StreamController<AuthState> authStateController;

  setUp(() {
    mockGoTrueClient = MockGoTrueClient();
    authStateController = StreamController<AuthState>();

    // Mock the SupabaseService to use the mock client
    SupabaseService.auth = mockGoTrueClient;

    when(() => mockGoTrueClient.onAuthStateChange)
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('Auth Providers', () {
    test('authStateProvider emits user when auth state changes', () async {
      final container = ProviderContainer();
      final user = FakeUser();
      final session = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: user,
      );
      final authState = AuthState(event: AuthChangeEvent.signedIn, session: session);

      final expectation = expectLater(
        container.read(authStateProvider.stream),
        emits(user),
      );

      authStateController.add(authState);
      await expectation;
    });

    test('currentUserProvider returns user when authenticated', () async {
        final container = ProviderContainer();
        final user = FakeUser();
        final session = Session(
            accessToken: 'token',
            tokenType: 'bearer',
            user: user,
        );
        final authState = AuthState(event: AuthChangeEvent.signedIn, session: session);

        authStateController.add(authState);

        // Allow the stream to propagate
        await Future.delayed(Duration.zero);

        final result = container.read(currentUserProvider);
        expect(result, user);
    });

     test('currentUserProvider returns null when not authenticated', () async {
        final container = ProviderContainer();
        final authState = AuthState(event: AuthChangeEvent.signedOut, session: null);

        authStateController.add(authState);
        await Future.delayed(Duration.zero);

        final result = container.read(currentUserProvider);
        expect(result, isNull);
    });

     test('isAuthenticatedProvider returns true when authenticated', () async {
        final container = ProviderContainer();
        final user = FakeUser();
        final session = Session(
            accessToken: 'token',
            tokenType: 'bearer',
            user: user,
        );
        final authState = AuthState(event: AuthChangeEvent.signedIn, session: session);

        authStateController.add(authState);

        await Future.delayed(Duration.zero);

        final result = container.read(isAuthenticatedProvider);
        expect(result, isTrue);
    });

     test('isAuthenticatedProvider returns false when not authenticated', () async {
        final container = ProviderContainer();
        final authState = AuthState(event: AuthChangeEvent.signedOut, session: null);

        authStateController.add(authState);
        await Future.delayed(Duration.zero);

        final result = container.read(isAuthenticatedProvider);
        expect(result, isFalse);
    });

  });
}
