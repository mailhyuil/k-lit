import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';

/// 책 목록 상태
class BookListState {
  final List<Book> books;
  final bool isLoading;
  final String? error;

  const BookListState({
    this.books = const [],
    this.isLoading = false,
    this.error,
  });

  BookListState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? error,
  }) {
    return BookListState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 책 목록 컨트롤러
class BookListController extends Notifier<BookListState> {
  @override
  BookListState build() {
    loadBooks();
    return const BookListState();
  }

  /// 책 목록 로드 (스텁)
  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: 실제 Supabase에서 책 목록 가져오기
      await Future.delayed(const Duration(seconds: 1));
      // 플레이스홀더 데이터
      state = state.copyWith(
        books: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '책 목록을 불러오는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadBooks();
  }
}

/// 책 목록 컨트롤러 프로바이더
final bookListControllerProvider =
    NotifierProvider<BookListController, BookListState>(
  () => BookListController(),
);

