import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';

import '../models/collection.dart';
import '../providers/collection_provider.dart';
import '../widgets/collection_card.dart';
import 'collection_detail_page.dart';

/// 컬렉션 목록 페이지
class CollectionListPage extends ConsumerWidget {
  const CollectionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseControllerProvider);
    if (!purchase.ready) {
      //TODO: SplashView 로 변경
      return const Center(child: CircularProgressIndicator()); // 로딩/스플래시
    }
    final collectionsAsync = ref.watch(collectionsWithStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('컬렉션'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(collectionsWithStatusProvider.future),
        child: collectionsAsync.when(
          data: (collections) {
            if (collections.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCollectionGrid(context, collections);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_bookmark_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('등록된 컬렉션이 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '컬렉션 목록을 불러오는 중 오류가 발생했습니다',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(collectionsProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionGrid(BuildContext context, List<Collection> collections) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
                builder: (context) => CollectionDetailPage(collectionId: collection.id),
              ),
            );
          },
        );
      },
    );
  }
}
