import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/revenuecat_config.dart';
import 'core/config/supabase_client.dart';
import 'features/auth/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('환경 변수 로드 실패: $e');
    // .env 파일이 없어도 계속 진행 (개발용)
  }

  // Supabase 초기화
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase 초기화 실패: $e');
    // Supabase 초기화 실패해도 계속 진행 (개발용)
  }

  // RevenueCat 초기화
  try {
    await RevenueCatConfig.initialize();
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }
    await RevenueCatConfig.setUserId(user.id);
  } catch (e) {
    debugPrint('RevenueCat 초기화 실패: $e');
    // RevenueCat 초기화 실패해도 계속 진행 (개발용)
  }

  runApp(const ProviderScope(child: MyApp())); // riverpod scope 설정
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-LIT',
      theme: ThemeData(
        fontFamily: 'NotoNaskhArabic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 189, 224, 109),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: 'NotoNaskhArabic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 42, 49, 28),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
