import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_lit/features/collections/models/collection.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';
import 'package:k_lit/features/purchase/widgets/story_detail_dialog.dart';
import 'package:k_lit/l10n/app_localizations.dart';

import '../../stories/models/story.dart';
import '../../stories/providers/story_provider.dart';
import '../providers/collection_provider.dart';

/// 컬렉션 상세 페이지
class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final collectionAsync = ref.watch(collectionByIdProvider(collectionId));
    final storiesAsync = ref.watch(storiesByCollectionIdProvider(collectionId));
    final purchaseController = ref.read(purchaseControllerProvider.notifier);
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
                child: _buildCollectionInfo(
                  context,
                  collection,
                  purchaseController,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    t.storyList,
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
                  collection,
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
            onPressed: () => context.pop(),
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

  Widget _buildCollectionInfo(
    BuildContext context,
    Collection collection,
    PurchaseController purchaseController,
  ) {
    final t = AppLocalizations.of(context)!;
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
                  label: Text(t.freeContent),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                ),
              if (collection.isPurchased && !collection.isFree)
                Chip(
                  label: Text(t.purchased),
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
                onPressed: () =>
                    purchaseController.handlePurchase(context, collection),
                icon: const Icon(Icons.shopping_cart),
                label: Text('${t.buyCollection} (\$${collection.price})'),
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
    Collection collection,
  ) {
    final t = AppLocalizations.of(context)!;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final story = stories[index];
        final canRead = hasAccess || story.isFree;

        return ListTile(
          leading: CircleAvatar(
            child: Text(
              '${index + 1}',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ),
          title: Text(
            story.titleAr,
            textDirection: t.localeName == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: t.localeName == 'ar' ? TextAlign.right : TextAlign.left,
          ),
          subtitle: story.isFree
              ? Text(t.freeContent, style: TextStyle(color: Colors.green))
              : null,
          trailing: canRead
              ? const Icon(Icons.chevron_right)
              : const Icon(Icons.lock_outline),
          onTap: canRead
              ? () {
                  context.push('/stories/${story.id}');
                }
              : () => _showStoryDetailDialog(context, story, collection),
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
            onPressed: () => context.pop(),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  void _showLockSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이 작품을 읽으려면 컬렉션을 구매해야 합니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showStoryDetailDialog(
    BuildContext context,
    Story story,
    Collection collection,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          StoryDetailDialog(story: story, collection: collection),
    );
  }
}
