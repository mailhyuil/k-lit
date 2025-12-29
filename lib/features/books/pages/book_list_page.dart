import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';

/// 책 목록 페이지
class BookListPage extends ConsumerWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookListState = ref.watch(bookListControllerProvider);
    final bookListController = ref.read(bookListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
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
        onRefresh: () => bookListController.refresh(),
        child: _buildBody(bookListState, bookListController),
      ),
    );
  }

  Widget _buildBody(
    BookListState state,
    BookListController controller,
  ) {
    if (state.isLoading && state.books.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 책이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.books.length,
      itemBuilder: (context, index) {
        final book = state.books[index];
        return BookCard(
          book: book,
          onTap: () {
            // TODO: Book Viewer로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${book.title} 선택됨')),
            );
          },
        );
      },
    );
  }
}

