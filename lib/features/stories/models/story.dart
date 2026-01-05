/// Story (작품) 모델 - Hybrid Storage
///
/// DB: 제목, 서문(intro), 해설(commentary) - 미리보기용
/// Storage: 본문(body) - 구입 후 다운로드

typedef StoryCollection = ({String id, String? rcIdentifier});
typedef StoryCollections = List<StoryCollection>;

class Story {
  final String id;
  final String titleAr; // 아랍어 제목
  final StoryCollections collections;
  // DB에 저장 (미리보기용 - 무료 공개)
  final String? introAr; // 아랍어 서문
  final String? commentaryAr; // 아랍어 해설/주석

  // Storage 참조 (본문 - 구입 후 다운로드)
  final String contentUrl; // Storage 경로 (예: 'story-contents/{id}.json')
  final int contentVersion; // 콘텐츠 버전 (캐시 무효화용)
  final int? contentSizeBytes; // 파일 크기 (다운로드 예상 시간 표시용)

  final int orderIndex; // 컬렉션 내 정렬 순서
  final bool isFree; // 무료 체험용 작품 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  const Story({
    required this.id,
    required this.collections,
    required this.titleAr,
    this.introAr,
    this.commentaryAr,
    required this.contentUrl,
    required this.contentVersion,
    this.contentSizeBytes,
    required this.orderIndex,
    required this.isFree,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Story.fromMap(Map<String, dynamic> map) {
    final storyCollections = (map['story_collections'] as List<dynamic>).map((
      sc,
    ) {
      final collection = sc['collections'] as Map<String, dynamic>;
      return (
        id: collection['id'] as String,
        rcIdentifier: collection['rc_identifier'] as String?,
      );
    }).toList();
    return Story(
      id: map['id'] as String,
      collections: storyCollections,
      titleAr: map['title_ar'] as String,
      introAr: map['intro_ar'] as String?,
      commentaryAr: map['commentary_ar'] as String?,
      contentUrl: map['content_url'] as String,
      contentVersion: map['content_version'] as int? ?? 1,
      contentSizeBytes: map['content_size_bytes'] as int?,
      orderIndex: map['order_index'] as int? ?? 0,
      isFree: map['is_free'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// copyWith 메서드
  Story copyWith({
    String? id,
    StoryCollections? collections,
    String? titleAr,
    String? introAr,
    String? commentaryAr,
    String? contentUrl,
    int? contentVersion,
    int? contentSizeBytes,
    int? orderIndex,
    bool? isFree,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Story(
      id: id ?? this.id,
      collections: collections ?? this.collections,
      titleAr: titleAr ?? this.titleAr,
      introAr: introAr ?? this.introAr,
      commentaryAr: commentaryAr ?? this.commentaryAr,
      contentUrl: contentUrl ?? this.contentUrl,
      contentVersion: contentVersion ?? this.contentVersion,
      contentSizeBytes: contentSizeBytes ?? this.contentSizeBytes,
      orderIndex: orderIndex ?? this.orderIndex,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 예상 다운로드 시간 (초) - 모바일 4G 기준 (5 Mbps)
  int get estimatedDownloadSeconds {
    if (contentSizeBytes == null) return 0;
    final mbps = 5; // 5 Mbps
    final bytesPerSecond = (mbps * 1024 * 1024) / 8;
    return (contentSizeBytes! / bytesPerSecond).ceil();
  }

  /// 파일 크기 (MB)
  double get contentSizeMB {
    if (contentSizeBytes == null) return 0;
    return contentSizeBytes! / (1024 * 1024);
  }

  /// 전체 콘텐츠 조합 (intro + body + commentary)
  /// [bodyAr]는 Storage에서 로드한 본문 텍스트
  String getFullContent(String bodyAr) {
    final parts = <String>[];

    if (introAr != null && introAr!.isNotEmpty) {
      parts.add(introAr!);
    }

    if (bodyAr.isNotEmpty) {
      parts.add(bodyAr);
    }

    if (commentaryAr != null && commentaryAr!.isNotEmpty) {
      parts.add(commentaryAr!);
    }

    return parts.join('\n\n');
  }

  @override
  String toString() {
    return 'Story(id: $id, titleAr: $titleAr, isFree: $isFree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Story && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
