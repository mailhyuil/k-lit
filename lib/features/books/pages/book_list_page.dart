import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';
import '../models/book.dart'; // Added import for Book model

/// 책 목록 페이지
class BookListPage extends ConsumerWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookListAsyncValue = ref.watch(bookListWithPurchaseStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('책 목록'), // Changed title
        actions: [
          // My Page 버튼 (플레이스홀더)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: My Page로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My Page는 아직 구현되지 않았습니다.')),
              );
            },
            tooltip: 'My Page',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(booksProvider.future), // Invalidate booksProvider
        child: bookListAsyncValue.when(
          data: (books) {
            if (books.isEmpty) {
              return _buildEmptyState();
            }
            return _buildBookGrid(books);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, ref, error),
        ),
      ),
    );
  }

  // Extracted methods for better readability and reusability
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '등록된 책이 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
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
            '책 목록을 불러오는 중 오류가 발생했습니다: ${error.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(booksProvider), // Invalidate to retry
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          isPurchased: book.isPurchased, // Pass isPurchased status
          onTap: () {
            // TODO: Book Viewer로 이동
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('${book.title} 선택됨')));
          },
        );
      },
    );
  }
}
