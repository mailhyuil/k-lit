import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/revenuecat_config.dart';
import 'core/config/supabase_client.dart';
import 'features/auth/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 환경 변수 로드
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('환경 변수 로드 실패: $e');
    // .env 파일이 없어도 계속 진행 (개발용)
  }

  try {
    // Supabase 초기화
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase 초기화 실패: $e');
    // Supabase 초기화 실패해도 계속 진행 (개발용)
  }

  try {
    // RevenueCat 초기화
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

  runApp(const ProviderScope(child: MyApp()));
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
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
