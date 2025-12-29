import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/books/models/book.dart';

void main() {
  group('Book', () {
    test('Book.fromMap creates a valid Book object', () {
      final Map<String, dynamic> bookMap = {
        'id': '1',
        'title': 'Test Book',
        'author': 'Test Author',
        'cover_url': 'http://example.com/cover.jpg',
        'description': 'A test description',
        'language': 'en',
      };

      final book = Book.fromMap(bookMap);

      expect(book.id, '1');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.coverUrl, 'http://example.com/cover.jpg');
      expect(book.description, 'A test description');
      expect(book.language, 'en');
      expect(book.isPurchased, false); // Default value
    });

    test('Book.copyWith creates a new Book object with updated values', () {
      const originalBook = Book(
        id: '1',
        title: 'Original Title',
        author: 'Original Author',
        language: 'en',
        isPurchased: false,
      );

      final updatedBook = originalBook.copyWith(
        title: 'Updated Title',
        isPurchased: true,
      );

      expect(updatedBook.id, '1');
      expect(updatedBook.title, 'Updated Title');
      expect(updatedBook.author, 'Original Author');
      expect(updatedBook.language, 'en');
      expect(updatedBook.isPurchased, true);
    });
  });
}
