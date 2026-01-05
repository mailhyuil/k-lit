import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';

import '../../stories/models/story.dart';
import '../../stories/providers/story_provider.dart';
import '../models/collection.dart';
import 'collection_provider.dart';

/// 검색 결과 타입
enum SearchResultType { collection, story }

/// 통합 검색 결과
class SearchResult {
  final SearchResultType type;
  final String id;
  final String title;
  final String? description;
  final bool isFree;
  final bool isPurchased;
  final String collectionId;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.isFree,
    required this.isPurchased,
    required this.collectionId,
    this.description,
  });

  factory SearchResult.fromCollection(Collection collection) {
    return SearchResult(
      type: SearchResultType.collection,
      id: collection.id,
      title: collection.titleAr,
      description: collection.descriptionAr,
      isFree: collection.isFree,
      isPurchased: collection.isPurchased,
      collectionId: collection.id,
    );
  }

  factory SearchResult.fromStory(Story story, {bool isPurchased = false}) {
    return SearchResult(
      type: SearchResultType.story,
      id: story.id,
      title: story.titleAr,
      description: story.introAr,
      isFree: story.isFree,
      isPurchased: isPurchased,
      collectionId: story.collections.first.id,
    );
  }
}

/// 검색 상태
class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 검색 컨트롤러
class SearchController extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  /// 검색 쿼리 업데이트 (Debounce 적용)
  void updateQuery(String query) {
    // 즉시 로딩 상태로 전환
    state = state.copyWith(query: query, isLoading: true);

    // 기존 타이머 취소
    _debounceTimer?.cancel();

    // 빈 쿼리면 결과 초기화
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    // 300ms 후 실제 검색 수행
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// 실제 검색 수행
  Future<void> _performSearch(String query) async {
    try {
      final lowerQuery = query.toLowerCase();

      // Collection 검색
      final collections = await ref.read(purchasedCollectionsProvider.future);
      final collectionResults = collections
          .where(
            (c) =>
                c.titleAr.toLowerCase().contains(lowerQuery) ||
                (c.descriptionAr?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .map((c) => SearchResult.fromCollection(c))
          .toList();

      // Story 검색
      final stories = await ref.read(storiesProvider.future);
      // 구매여부 확인
      final customerInfo = ref.read(customerInfoProvider);
      final storyResults = stories
          .where(
            (s) =>
                s.titleAr.toLowerCase().contains(lowerQuery) ||
                (s.introAr?.toLowerCase().contains(lowerQuery) ?? false) ||
                (s.commentaryAr?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .map(
            (s) => SearchResult.fromStory(
              s,
              isPurchased:
                  customerInfo?.allPurchasedProductIdentifiers.contains(
                    s.collections.first.rcIdentifier,
                  ) ??
                  false,
            ),
          )
          .toList();

      // 결과 결합 (Collection 우선)
      final results = [...collectionResults, ...storyResults];

      state = state.copyWith(results: results, isLoading: false, error: null);
    } catch (e, stack) {
      debugPrint('Search error: $e\n$stack');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 검색 초기화
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }
}

/// 검색 컨트롤러 Provider
final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(() => SearchController());
