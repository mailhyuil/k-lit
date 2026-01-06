import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

typedef StoryCollection = ({String id, String? rcIdentifier});
typedef StoryCollections = List<StoryCollection>;

@freezed
abstract class Story with _$Story {
  const Story._();
  const factory Story({
    required String id,
    @JsonKey(name: 'title_ar') required String titleAr,
    @JsonKey(name: 'intro_ar') required String? introAr,
    @JsonKey(name: 'commentary_ar') required String? commentaryAr,
    @JsonKey(name: 'content_url') required String contentUrl,
    @JsonKey(name: 'content_version') required int contentVersion,
    @JsonKey(name: 'is_free') required bool isFree,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'order_index') required int orderIndex,
    @JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson)
    required StoryCollections collections,
    required int? contentSizeBytes,
  }) = _Story;

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

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
}

List<StoryCollection> _storyCollectionsFromJson(dynamic json) {
  if (json is! List) return [];

  return json.map((sc) {
    final collection = sc['collections'] as Map<String, dynamic>;
    return (
      id: collection['id'] as String,
      rcIdentifier: collection['rc_identifier'] as String?,
    );
  }).toList();
}
