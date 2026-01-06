// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Collection _$CollectionFromJson(Map<String, dynamic> json) => _Collection(
  id: json['id'] as String,
  titleAr: json['title_ar'] as String,
  descriptionAr: json['description_ar'] as String?,
  coverUrl: json['cover_url'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  orderIndex: (json['order_index'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  isPurchased: json['is_purchased'] as bool? ?? false,
  isFree: json['is_free'] as bool? ?? false,
  storyCount: json['stories'] == null
      ? 0
      : _storyCountFromJson(json['stories']),
  rcIdentifier: json['rc_identifier'] as String?,
);

Map<String, dynamic> _$CollectionToJson(_Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title_ar': instance.titleAr,
      'description_ar': instance.descriptionAr,
      'cover_url': instance.coverUrl,
      'price': instance.price,
      'order_index': instance.orderIndex,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_purchased': instance.isPurchased,
      'is_free': instance.isFree,
      'stories': instance.storyCount,
      'rc_identifier': instance.rcIdentifier,
    };
