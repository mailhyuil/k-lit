import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_lit/l10n/app_localizations.dart';

import '../../collections/providers/collection_provider.dart';
import '../../collections/widgets/collection_card.dart';
import '../providers/auth_controller.dart';
import '../providers/profile_provider.dart';

/// My Page - 사용자 프로필 및 구매한 컬렉션 목록
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final purchasedCollectionsAsync = ref.watch(purchasedCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.myPage),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(purchasedCollectionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 구매한 컬렉션 섹션 헤더
            Text(
              t.purchasedCollections,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 구매한 컬렉션 목록
            _buildPurchasedCollections(context, ref, purchasedCollectionsAsync),
          ],
        ),
      ),
      // 로그아웃 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 12),
              _buildLogoutSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// 구매한 컬렉션 목록
  Widget _buildPurchasedCollections(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List> collectionsAsync,
  ) {
    final t = AppLocalizations.of(context)!;
    return collectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            return CollectionCard(
              collection: collection,
              onTap: () {
                context.go('/collections/${collection.id}');
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '컬렉션을 불러오는 중 오류가 발생했습니다',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(purchasedCollectionsProvider);
              },
              child: Text(t.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State - 구매한 컬렉션이 없을 때
  Widget _buildEmptyState(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              t.noPurchasedCollections,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 섹션
  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          t.logout,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).signOut();

      // 로그아웃 후 LoginPage로 이동 (navigation stack 정리)
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
