import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/login_page.dart';
import '../providers/auth_providers.dart';
import '../../navigation/pages/main_navigation.dart';

/// 인증 상태에 따라 라우팅을 결정하는 위젯
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigation();
        } else {
          return const LoginPage();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        // 에러 발생 시에도 LoginPage로 이동 (개발용)
        debugPrint('AuthGate 에러: $error');
        debugPrint('Stack: $stack');
        return const LoginPage();
      },
    );
  }
}
