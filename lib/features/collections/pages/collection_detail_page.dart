import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../purchase/widgets/purchase_dialog.dart';
import '../../stories/models/story.dart';
import '../../stories/pages/story_reader_page.dart';
import '../../stories/providers/story_provider.dart';
import '../providers/collection_provider.dart';

/// 컬렉션 상세 페이지
class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionByIdProvider(collectionId));
    final storiesAsync = ref.watch(collectionStoriesProvider(collectionId));
    return Scaffold(
      body: collectionAsync.when(
        data: (collection) {
          if (collection == null) {
            return _buildNotFound(context);
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, collection),
              SliverToBoxAdapter(
                child: _buildCollectionInfo(context, collection),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '작품 목록',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              storiesAsync.when(
                data: (stories) => _buildStoryList(
                  context,
                  ref,
                  stories,
                  collection.isPurchased || collection.isFree,
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stack) =>
                    SliverToBoxAdapter(child: _buildErrorState(context, error)),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorScreen(context, error),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('컬렉션을 찾을 수 없습니다'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic collection) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            collection.titleAr,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: collection.coverUrl != null
            ? Image.network(
                collection.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderCover(),
              )
            : _buildPlaceholderCover(),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(
        Icons.collections_bookmark,
        size: 100,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildCollectionInfo(BuildContext context, dynamic collection) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명
          if (collection.descriptionAr != null) ...[
            Text(
              collection.descriptionAr!,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
          ],
          // 상태
          Row(
            children: [
              if (collection.isFree)
                Chip(
                  label: const Text('무료 컬렉션'),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
              if (collection.isPurchased && !collection.isFree)
                Chip(
                  label: const Text('구매완료'),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: TextStyle(color: Colors.green.shade700),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 구매 버튼 (미구매 유료 컬렉션인 경우)
          if (!collection.isPurchased && !collection.isFree)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handlePurchase(context, collection),
                icon: const Icon(Icons.shopping_cart),
                label: Text('컬렉션 구매 (\$2.99)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryList(
    BuildContext context,
    WidgetRef ref,
    List<Story> stories,
    bool hasAccess,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final story = stories[index];
        final canRead = hasAccess || story.isFree;

        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(
            story.titleAr,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          subtitle: story.isFree
              ? const Text('무료 체험', style: TextStyle(color: Colors.green))
              : null,
          trailing: canRead
              ? const Icon(Icons.chevron_right)
              : const Icon(Icons.lock_outline),
          onTap: canRead
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StoryReaderPage(
                        hasAccess: hasAccess,
                        storyId: story.id,
                      ),
                    ),
                  );
                }
              : () => _showLockMessage(context),
        );
      }, childCount: stories.length),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        '작품 목록을 불러오는 중 오류가 발생했습니다: $error',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('오류: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context, dynamic collection) async {
    // RevenueCat 구매 다이얼로그 표시
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PurchaseDialog(collection: collection),
    );

    // 구매 성공 시 페이지 새로고침
    if (result == true && context.mounted) {
      // 컬렉션 목록 새로고침
      // ref는 build 메서드에서만 사용 가능하므로 여기서는 별도 처리 불필요
    }
  }

  void _showLockMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이 작품을 읽으려면 컬렉션을 구매해야 합니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
