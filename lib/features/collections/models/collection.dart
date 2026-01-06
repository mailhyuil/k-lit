import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed
abstract class Collection with _$Collection {
  const factory Collection({
    required String id,
    @JsonKey(name: 'title_ar') required String titleAr,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    @JsonKey(name: 'cover_url') String? coverUrl,
    @JsonKey(name: 'price') double? price,
    @JsonKey(name: 'order_index') int? orderIndex,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'is_purchased', defaultValue: false)
    required bool isPurchased,
    @JsonKey(name: 'is_free', defaultValue: false) required bool isFree,
    @JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0)
    required int storyCount,
    @JsonKey(name: 'rc_identifier') String? rcIdentifier,
  }) = _Collection;

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
}

// storyCount = json['stories']?[0]?['count'] as int? ?? 0,
int _storyCountFromJson(dynamic json) {
  return json is List && json.isNotEmpty ? (json[0]?['count'] as int?) ?? 0 : 0;
}
