import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_client.dart';

/// 인증 컨트롤러 상태
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 인증 컨트롤러
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Google 로그인 (스텁)
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 실제 Google 로그인 구현
      await Future.delayed(const Duration(seconds: 1));
      throw UnimplementedError('Google 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Facebook 로그인 (스텁)
  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 실제 Facebook 로그인 구현
      await Future.delayed(const Duration(seconds: 1));
      throw UnimplementedError('Facebook 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Apple 로그인 (스텁)
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 실제 Apple 로그인 구현
      await Future.delayed(const Duration(seconds: 1));
      throw UnimplementedError('Apple 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await SupabaseService.auth.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return '로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
    if (error.toString().contains('network') || error.toString().contains('Network')) {
      return '네트워크 상태를 확인해주세요.';
    }
    if (error.toString().contains('cancel')) {
      return '로그인이 취소되었습니다.';
    }
    return '예기치 못한 오류가 발생했습니다.';
  }
}

/// 인증 컨트롤러 프로바이더
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  () => AuthController(),
);

