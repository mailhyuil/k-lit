// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Story {

 String get id;@JsonKey(name: 'title_ar') String get titleAr;@JsonKey(name: 'intro_ar') String? get introAr;@JsonKey(name: 'commentary_ar') String? get commentaryAr;@JsonKey(name: 'content_url') String get contentUrl;@JsonKey(name: 'content_version') int get contentVersion;@JsonKey(name: 'is_free') bool get isFree;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'order_index') int get orderIndex;@JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson) StoryCollections get collections; int? get contentSizeBytes;
/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCopyWith<Story> get copyWith => _$StoryCopyWithImpl<Story>(this as Story, _$identity);

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Story&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.introAr, introAr) || other.introAr == introAr)&&(identical(other.commentaryAr, commentaryAr) || other.commentaryAr == commentaryAr)&&(identical(other.contentUrl, contentUrl) || other.contentUrl == contentUrl)&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other.collections, collections)&&(identical(other.contentSizeBytes, contentSizeBytes) || other.contentSizeBytes == contentSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,introAr,commentaryAr,contentUrl,contentVersion,isFree,createdAt,updatedAt,orderIndex,const DeepCollectionEquality().hash(collections),contentSizeBytes);

@override
String toString() {
  return 'Story(id: $id, titleAr: $titleAr, introAr: $introAr, commentaryAr: $commentaryAr, contentUrl: $contentUrl, contentVersion: $contentVersion, isFree: $isFree, createdAt: $createdAt, updatedAt: $updatedAt, orderIndex: $orderIndex, collections: $collections, contentSizeBytes: $contentSizeBytes)';
}


}

/// @nodoc
abstract mixin class $StoryCopyWith<$Res>  {
  factory $StoryCopyWith(Story value, $Res Function(Story) _then) = _$StoryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'title_ar') String titleAr,@JsonKey(name: 'intro_ar') String? introAr,@JsonKey(name: 'commentary_ar') String? commentaryAr,@JsonKey(name: 'content_url') String contentUrl,@JsonKey(name: 'content_version') int contentVersion,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson) StoryCollections collections, int? contentSizeBytes
});




}
/// @nodoc
class _$StoryCopyWithImpl<$Res>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._self, this._then);

  final Story _self;
  final $Res Function(Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleAr = null,Object? introAr = freezed,Object? commentaryAr = freezed,Object? contentUrl = null,Object? contentVersion = null,Object? isFree = null,Object? createdAt = null,Object? updatedAt = null,Object? orderIndex = null,Object? collections = null,Object? contentSizeBytes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,introAr: freezed == introAr ? _self.introAr : introAr // ignore: cast_nullable_to_non_nullable
as String?,commentaryAr: freezed == commentaryAr ? _self.commentaryAr : commentaryAr // ignore: cast_nullable_to_non_nullable
as String?,contentUrl: null == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String,contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as StoryCollections,contentSizeBytes: freezed == contentSizeBytes ? _self.contentSizeBytes : contentSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Story].
extension StoryPatterns on Story {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Story value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Story value)  $default,){
final _that = this;
switch (_that) {
case _Story():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Story value)?  $default,){
final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'intro_ar')  String? introAr, @JsonKey(name: 'commentary_ar')  String? commentaryAr, @JsonKey(name: 'content_url')  String contentUrl, @JsonKey(name: 'content_version')  int contentVersion, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson)  StoryCollections collections,  int? contentSizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.titleAr,_that.introAr,_that.commentaryAr,_that.contentUrl,_that.contentVersion,_that.isFree,_that.createdAt,_that.updatedAt,_that.orderIndex,_that.collections,_that.contentSizeBytes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'intro_ar')  String? introAr, @JsonKey(name: 'commentary_ar')  String? commentaryAr, @JsonKey(name: 'content_url')  String contentUrl, @JsonKey(name: 'content_version')  int contentVersion, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson)  StoryCollections collections,  int? contentSizeBytes)  $default,) {final _that = this;
switch (_that) {
case _Story():
return $default(_that.id,_that.titleAr,_that.introAr,_that.commentaryAr,_that.contentUrl,_that.contentVersion,_that.isFree,_that.createdAt,_that.updatedAt,_that.orderIndex,_that.collections,_that.contentSizeBytes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'intro_ar')  String? introAr, @JsonKey(name: 'commentary_ar')  String? commentaryAr, @JsonKey(name: 'content_url')  String contentUrl, @JsonKey(name: 'content_version')  int contentVersion, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson)  StoryCollections collections,  int? contentSizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.titleAr,_that.introAr,_that.commentaryAr,_that.contentUrl,_that.contentVersion,_that.isFree,_that.createdAt,_that.updatedAt,_that.orderIndex,_that.collections,_that.contentSizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Story extends Story {
  const _Story({required this.id, @JsonKey(name: 'title_ar') required this.titleAr, @JsonKey(name: 'intro_ar') required this.introAr, @JsonKey(name: 'commentary_ar') required this.commentaryAr, @JsonKey(name: 'content_url') required this.contentUrl, @JsonKey(name: 'content_version') required this.contentVersion, @JsonKey(name: 'is_free') required this.isFree, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'order_index') required this.orderIndex, @JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson) required final  StoryCollections collections, required this.contentSizeBytes}): _collections = collections,super._();
  factory _Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'title_ar') final  String titleAr;
@override@JsonKey(name: 'intro_ar') final  String? introAr;
@override@JsonKey(name: 'commentary_ar') final  String? commentaryAr;
@override@JsonKey(name: 'content_url') final  String contentUrl;
@override@JsonKey(name: 'content_version') final  int contentVersion;
@override@JsonKey(name: 'is_free') final  bool isFree;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'order_index') final  int orderIndex;
 final  StoryCollections _collections;
@override@JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson) StoryCollections get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

@override final  int? contentSizeBytes;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCopyWith<_Story> get copyWith => __$StoryCopyWithImpl<_Story>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Story&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.introAr, introAr) || other.introAr == introAr)&&(identical(other.commentaryAr, commentaryAr) || other.commentaryAr == commentaryAr)&&(identical(other.contentUrl, contentUrl) || other.contentUrl == contentUrl)&&(identical(other.contentVersion, contentVersion) || other.contentVersion == contentVersion)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other._collections, _collections)&&(identical(other.contentSizeBytes, contentSizeBytes) || other.contentSizeBytes == contentSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,introAr,commentaryAr,contentUrl,contentVersion,isFree,createdAt,updatedAt,orderIndex,const DeepCollectionEquality().hash(_collections),contentSizeBytes);

@override
String toString() {
  return 'Story(id: $id, titleAr: $titleAr, introAr: $introAr, commentaryAr: $commentaryAr, contentUrl: $contentUrl, contentVersion: $contentVersion, isFree: $isFree, createdAt: $createdAt, updatedAt: $updatedAt, orderIndex: $orderIndex, collections: $collections, contentSizeBytes: $contentSizeBytes)';
}


}

/// @nodoc
abstract mixin class _$StoryCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$StoryCopyWith(_Story value, $Res Function(_Story) _then) = __$StoryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'title_ar') String titleAr,@JsonKey(name: 'intro_ar') String? introAr,@JsonKey(name: 'commentary_ar') String? commentaryAr,@JsonKey(name: 'content_url') String contentUrl,@JsonKey(name: 'content_version') int contentVersion,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'story_collections', fromJson: _storyCollectionsFromJson) StoryCollections collections, int? contentSizeBytes
});




}
/// @nodoc
class __$StoryCopyWithImpl<$Res>
    implements _$StoryCopyWith<$Res> {
  __$StoryCopyWithImpl(this._self, this._then);

  final _Story _self;
  final $Res Function(_Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleAr = null,Object? introAr = freezed,Object? commentaryAr = freezed,Object? contentUrl = null,Object? contentVersion = null,Object? isFree = null,Object? createdAt = null,Object? updatedAt = null,Object? orderIndex = null,Object? collections = null,Object? contentSizeBytes = freezed,}) {
  return _then(_Story(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,introAr: freezed == introAr ? _self.introAr : introAr // ignore: cast_nullable_to_non_nullable
as String?,commentaryAr: freezed == commentaryAr ? _self.commentaryAr : commentaryAr // ignore: cast_nullable_to_non_nullable
as String?,contentUrl: null == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String,contentVersion: null == contentVersion ? _self.contentVersion : contentVersion // ignore: cast_nullable_to_non_nullable
as int,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as StoryCollections,contentSizeBytes: freezed == contentSizeBytes ? _self.contentSizeBytes : contentSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
