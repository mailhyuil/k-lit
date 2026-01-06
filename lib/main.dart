import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/core/config/global_error_handler.dart';
import 'package:k_lit/core/router/app_router.dart';
import 'package:k_lit/l10n/app_localizations.dart';

import 'core/config/revenuecat_config.dart';
import 'core/config/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Synchronous errors handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  // Asynchronous errors handling
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    return true;
  };

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

  runApp(
    ProviderScope(observers: [GlobalErrorHandler()], child: MyApp()),
  ); // riverpod scope 설정
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'K-LIT',
      routerConfig: appRouter,
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('ko')],
    );
  }
}
