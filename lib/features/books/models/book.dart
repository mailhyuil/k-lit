/// 책 모델
class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final String language;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    required this.language,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      language: json['language'] as String? ?? 'ar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'description': description,
      'language': language,
    };
  }
}

