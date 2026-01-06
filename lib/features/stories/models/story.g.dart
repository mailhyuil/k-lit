// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Story _$StoryFromJson(Map<String, dynamic> json) => _Story(
  id: json['id'] as String,
  titleAr: json['title_ar'] as String,
  introAr: json['intro_ar'] as String?,
  commentaryAr: json['commentary_ar'] as String?,
  contentUrl: json['content_url'] as String,
  contentVersion: (json['content_version'] as num).toInt(),
  isFree: json['is_free'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  orderIndex: (json['order_index'] as num).toInt(),
  collections: _storyCollectionsFromJson(json['story_collections']),
  contentSizeBytes: (json['contentSizeBytes'] as num?)?.toInt(),
);

Map<String, dynamic> _$StoryToJson(_Story instance) => <String, dynamic>{
  'id': instance.id,
  'title_ar': instance.titleAr,
  'intro_ar': instance.introAr,
  'commentary_ar': instance.commentaryAr,
  'content_url': instance.contentUrl,
  'content_version': instance.contentVersion,
  'is_free': instance.isFree,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'order_index': instance.orderIndex,
  'story_collections': instance.collections
      .map((e) => <String, dynamic>{'id': e.id, 'rcIdentifier': e.rcIdentifier})
      .toList(),
  'contentSizeBytes': instance.contentSizeBytes,
};
