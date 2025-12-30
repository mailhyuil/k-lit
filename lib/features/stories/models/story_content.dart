import 'dart:convert';

/// 작품 본문 콘텐츠 (Supabase Storage에서 다운로드)
/// 
/// ⚠️ intro_ar, commentary_ar은 DB에 저장되어 미리보기로 제공
/// ⚠️ body_ar만 Storage에 저장 (구입 후 다운로드)
/// 
/// Storage 파일 형식:
/// - arabic/{story_name}/content.txt : 본문 (순수 텍스트)
/// - arabic/{story_name}/_meta.json : {"version": 1}
class StoryContent {
  final int version;
  final String bodyAr;  // 본문만 Storage에 저장

  const StoryContent({
    required this.version,
    required this.bodyAr,
  });

  /// 텍스트 파일에서 생성
  factory StoryContent.fromText(String text, int version) {
    return StoryContent(
      version: version,
      bodyAr: text,
    );
  }

  /// 텍스트로 변환
  String toText() {
    return bodyAr;
  }

  /// 복사 생성자
  StoryContent copyWith({
    int? version,
    String? bodyAr,
  }) {
    return StoryContent(
      version: version ?? this.version,
      bodyAr: bodyAr ?? this.bodyAr,
    );
  }

  @override
  String toString() {
    return 'StoryContent(version: $version, bodyLength: ${bodyAr.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryContent &&
        other.version == version &&
        other.bodyAr == bodyAr;
  }

  @override
  int get hashCode {
    return Object.hash(version, bodyAr);
  }
}

/// 메타데이터 모델 (_meta.json)
class StoryMeta {
  final int version;

  const StoryMeta({
    required this.version,
  });

  factory StoryMeta.fromJson(Map<String, dynamic> json) {
    return StoryMeta(
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
    };
  }

  factory StoryMeta.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return StoryMeta.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  String toString() {
    return 'StoryMeta(version: $version)';
  }
}

/// 캐시된 콘텐츠 메타데이터
class CachedContentMetadata {
  final String storyId;
  final int version;
  final DateTime cachedAt;
  final int sizeBytes;

  const CachedContentMetadata({
    required this.storyId,
    required this.version,
    required this.cachedAt,
    required this.sizeBytes,
  });

  factory CachedContentMetadata.fromJson(Map<String, dynamic> json) {
    return CachedContentMetadata(
      storyId: json['story_id'] as String,
      version: json['version'] as int,
      cachedAt: DateTime.parse(json['cached_at'] as String),
      sizeBytes: json['size_bytes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story_id': storyId,
      'version': version,
      'cached_at': cachedAt.toIso8601String(),
      'size_bytes': sizeBytes,
    };
  }

  bool isExpired({Duration maxAge = const Duration(days: 30)}) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}
