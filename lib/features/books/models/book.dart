/// 책 모델
class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final String language;
  final bool isPurchased; // Added isPurchased field

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    required this.language,
    this.isPurchased = false, // Default to false
  });

  // Renamed fromJson to fromMap, and added isPurchased field
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      coverUrl: map['cover_url'] as String?,
      description: map['description'] as String?,
      language: map['language'] as String? ?? 'ar',
      isPurchased: false, // Default to false when creating from map
    );
  }

  // copyWith method
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    String? language,
    bool? isPurchased,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      language: language ?? this.language,
      isPurchased: isPurchased ?? this.isPurchased,
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
