import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/supabase_client.dart';
import '../../auth/providers/auth_providers.dart';
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

  BookListState copyWith({List<Book>? books, bool? isLoading, String? error}) {
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
    // No longer directly loading books here as it's handled by FutureProviders
    return const BookListState();
  }
}

/// 책 목록 컨트롤러 프로바이더
final bookListControllerProvider =
    NotifierProvider<BookListController, BookListState>(
      () => BookListController(),
    );

/// 모든 책 목록을 제공하는 프로바이더
final booksProvider = FutureProvider<List<Book>>((ref) async {
  // Mock data for development
  final List<Book> mockBooks = [
    Book(
      id: '1',
      title: '어린 왕자',
      author: '앙투안 드 생텍쥐페리',
      coverUrl: 'https://img.ridicdn.net/cover/3790000006/xxlarge',
      description: '사막에 불시착한 조종사가 다른 별에서 온 어린 왕자를 만나게 되는 이야기',
      language: 'ko',
    ),
    Book(
      id: '2',
      title: '노인과 바다',
      author: '어니스트 헤밍웨이',
      coverUrl:
          'https://contents.kyobobook.co.kr/sih/fit-in/450x450/pdt/9788937460188.jpg',
      description: '오랜 시간 고기를 잡지 못한 늙은 어부 산티아고가 거대한 청새치와 사투를 벌이는 이야기',
      language: 'ko',
    ),
    Book(
      id: '3',
      title: '데미안',
      author: '헤르만 헤세',
      coverUrl:
          'https://image.aladin.co.kr/product/2199/86/cover/8937462923_1.jpg',
      description: '싱클레어라는 소년이 성장하면서 겪는 내면의 갈등과 성장을 그린 소설',
      language: 'ko',
    ),
    Book(
      id: '4',
      title: '잃어버린 시간을 찾아서',
      author: '마르셀 프루스트',
      coverUrl:
          'https://image.aladin.co.kr/product/1572/35/cover/8937460838_1.jpg',
      description: '과거의 기억을 탐색하며 자아를 찾아가는 과정을 그린 대하소설',
      language: 'ko',
    ),
  ];
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return mockBooks;
});

/// 현재 사용자가 구매한 책 ID 목록을 제공하는 프로바이더
final purchasedBookIdsProvider = FutureProvider<Set<String>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (!isAuthenticated || currentUser == null) {
    return {}; // Return empty set if not authenticated
  }

  try {
    final response = await SupabaseService.instance.client
        .from('purchases')
        .select('book_id')
        .eq('user_id', currentUser.id);

    return response.map((map) => map['book_id'] as String).toSet();
  } catch (e) {
    debugPrint('Error fetching purchased book IDs: $e');
    return {}; // Return empty set on error
  }
});

/// 책 목록과 구매 상태를 결합하여 제공하는 프로바이더
final bookListWithPurchaseStatusProvider = FutureProvider<List<Book>>((
  ref,
) async {
  final booksAsyncValue = ref.watch(booksProvider);
  final purchasedBookIdsAsyncValue = ref.watch(purchasedBookIdsProvider);

  return booksAsyncValue.when(
    data: (books) {
      return purchasedBookIdsAsyncValue.when(
        data: (purchasedBookIds) {
          return books.map((book) {
            return book.copyWith(
              isPurchased: purchasedBookIds.contains(book.id),
            );
          }).toList();
        },
        loading: () => [], // Or throw an error, depending on desired behavior
        error: (error, stack) {
          debugPrint('Error combining books with purchased status: $error');
          return books; // Return books without purchase status on error
        },
      );
    },
    loading: () => [], // Return empty list while books are loading
    error: (error, stack) {
      debugPrint('Error fetching books for combination: $error');
      return []; // Return empty list on error
    },
  );
});
