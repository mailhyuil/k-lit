import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stories/pages/story_reader_page.dart';
import '../providers/search_provider.dart';
import 'collection_detail_page.dart';

/// 검색 페이지
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // 검색 입력
          _buildSearchBar(),
          // 검색 결과
          Expanded(child: _buildSearchResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '컬렉션 또는 작품 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchControllerProvider.notifier).clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          ref.read(searchControllerProvider.notifier).updateQuery(value);
          setState(() {}); // suffixIcon 업데이트용
        },
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    // 검색 전
    if (searchState.query.isEmpty) {
      return _buildEmptyState();
    }

    // 로딩 중
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 오류
    if (searchState.error != null) {
      return _buildErrorState(searchState.error!);
    }

    // 결과 없음
    if (searchState.results.isEmpty) {
      return _buildNoResultsState(searchState.query);
    }

    // 결과 표시
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final result = searchState.results[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('컬렉션 또는 작품을 검색하세요', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            '제목, 설명, 작품 내용으로 검색 가능',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('검색 결과가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            '"$query"',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('검색 중 오류가 발생했습니다', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleResultTap(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getResultColor(result).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getResultIcon(result), color: _getResultColor(result)),
              ),
              const SizedBox(width: 16),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      result.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.description!,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // 태그
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag(
                          result.type == SearchResultType.collection ? '컬렉션' : '작품',
                          Colors.blue,
                        ),
                        if (result.isFree) _buildTag('무료', Colors.green),
                        if (result.isPurchased && !result.isFree) _buildTag('구매완료', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              // 화살표
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getResultIcon(SearchResult result) {
    switch (result.type) {
      case SearchResultType.collection:
        return Icons.collections_bookmark;
      case SearchResultType.story:
        return Icons.article;
    }
  }

  Color _getResultColor(SearchResult result) {
    switch (result.type) {
      case SearchResultType.collection:
        return Colors.purple;
      case SearchResultType.story:
        return Colors.teal;
    }
  }

  void _handleResultTap(SearchResult result) {
    switch (result.type) {
      case SearchResultType.collection:
        // 컬렉션 상세로 이동
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CollectionDetailPage(collectionId: result.id)),
        );
        break;
      case SearchResultType.story:
        // 작품 읽기로 이동
        final hasAccess = result.isPurchased || result.isFree;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryReaderPage(hasAccess: hasAccess, storyId: result.id),
          ),
        );
        break;
    }
  }
}
