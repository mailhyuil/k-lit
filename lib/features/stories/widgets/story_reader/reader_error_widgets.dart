import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k_lit/core/theme/reader_theme.dart';

class ReaderErrorWidgets {
  static Widget buildNotFound(BuildContext context, ReaderThemeData theme) {
    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: theme.textColor.withAlpha((255 * 0.5).round()),
              ),
              const SizedBox(height: 24),
              Text(
                '작품을 찾을 수 없습니다',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.textColor,
                  foregroundColor: theme.backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildLockedState(BuildContext context, ReaderThemeData theme) {
    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: theme.textColor.withAlpha((255 * 0.7).round()),
                ),
                const SizedBox(height: 32),
                Text(
                  '잠긴 작품',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '이 작품을 읽으려면\n컬렉션을 구매해야 합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textColor.withAlpha((255 * 0.7).round()),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.textColor,
                    foregroundColor: theme.backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildErrorState(BuildContext context, Object error, ReaderThemeData theme) {
    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  '작품을 불러오는 중\n오류가 발생했습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor.withAlpha((255 * 0.6).round()),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.textColor,
                    foregroundColor: theme.backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildContentLoading(ReaderThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.textColor),
          const SizedBox(height: 16),
          Text(
            'المحتوى يتم تحميله...',
            style: TextStyle(fontSize: 16, color: theme.textColor),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static Widget buildContentError(Object e, ReaderThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.textColor),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل المحتوى',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            e.toString(),
            style: TextStyle(fontSize: 14, color: theme.textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
