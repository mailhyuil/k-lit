import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class GlobalErrorHandler extends ProviderObserver {
  GlobalErrorHandler() {
    debugPrint('GlobalErrorHandler 초기화');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    // 콘솔 출력
    FlutterError.dumpErrorToConsole(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );

    // Crashlytics / Sentry 등 리포팅 가능
  }
}
