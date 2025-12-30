import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_controller.dart';

/// 로그인 페이지
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Title / Logo
              const Text(
                '한국 문학',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '한국 문학 아랍어 번역본을 읽어보세요',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Google 로그인 버튼
              _SocialLoginButton(
                label: 'Google로 로그인',
                icon: Icons.g_mobiledata,
                onPressed: authState.isLoading
                    ? null
                    : () => authController.signInWithGoogle(),
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 16),

              // Facebook 로그인 버튼
              _SocialLoginButton(
                label: 'Facebook으로 로그인',
                icon: Icons.facebook,
                onPressed: authState.isLoading
                    ? null
                    : () => authController.signInWithFacebook(),
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 16),

              // Apple 로그인 버튼
              _SocialLoginButton(
                label: 'Apple로 로그인',
                icon: Icons.apple,
                onPressed: authState.isLoading
                    ? null
                    : () => authController.signInWithApple(),
                isLoading: authState.isLoading,
              ),

              // 에러 메시지
              if (authState.error != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    authState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 소셜 로그인 버튼 위젯
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon), const SizedBox(width: 8), Text(label)],
            ),
    );
  }
}
