import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/pages/collection_detail_page.dart';
import '../../collections/providers/collection_provider.dart';
import '../../collections/widgets/collection_card.dart';
import '../providers/auth_controller.dart';
import '../providers/profile_provider.dart';

/// My Page - 사용자 프로필 및 구매한 컬렉션 목록
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasedCollectionsAsync = ref.watch(purchasedCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이 페이지'),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.white),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
              '구매한 컬렉션',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 구매한 컬렉션 목록
            _buildPurchasedCollections(context, ref, purchasedCollectionsAsync),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            // 로그아웃 버튼
            _buildLogoutSection(context, ref),
          ],
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CollectionDetailPage(collectionId: collection.id),
                  ),
                );
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
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State - 구매한 컬렉션이 없을 때
  Widget _buildEmptyState(BuildContext context) {
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
              '구매한 컬렉션이 없습니다',
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
    final authState = ref.watch(authControllerProvider);

    return Center(
      child: ElevatedButton.icon(
        onPressed: authState.isLoading
            ? null
            : () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          '로그아웃',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).signOut();

      // 로그아웃 후 LoginPage로 이동 (navigation stack 정리)
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
