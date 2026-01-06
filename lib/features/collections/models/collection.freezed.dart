// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Collection {

 String get id;@JsonKey(name: 'title_ar') String get titleAr;@JsonKey(name: 'description_ar') String? get descriptionAr;@JsonKey(name: 'cover_url') String? get coverUrl;@JsonKey(name: 'price') double? get price;@JsonKey(name: 'order_index') int? get orderIndex;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'is_purchased', defaultValue: false) bool get isPurchased;@JsonKey(name: 'is_free', defaultValue: false) bool get isFree;@JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0) int get storyCount;@JsonKey(name: 'rc_identifier') String? get rcIdentifier;
/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionCopyWith<Collection> get copyWith => _$CollectionCopyWithImpl<Collection>(this as Collection, _$identity);

  /// Serializes this Collection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.price, price) || other.price == price)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.storyCount, storyCount) || other.storyCount == storyCount)&&(identical(other.rcIdentifier, rcIdentifier) || other.rcIdentifier == rcIdentifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,descriptionAr,coverUrl,price,orderIndex,createdAt,updatedAt,isPurchased,isFree,storyCount,rcIdentifier);

@override
String toString() {
  return 'Collection(id: $id, titleAr: $titleAr, descriptionAr: $descriptionAr, coverUrl: $coverUrl, price: $price, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt, isPurchased: $isPurchased, isFree: $isFree, storyCount: $storyCount, rcIdentifier: $rcIdentifier)';
}


}

/// @nodoc
abstract mixin class $CollectionCopyWith<$Res>  {
  factory $CollectionCopyWith(Collection value, $Res Function(Collection) _then) = _$CollectionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'title_ar') String titleAr,@JsonKey(name: 'description_ar') String? descriptionAr,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'price') double? price,@JsonKey(name: 'order_index') int? orderIndex,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'is_purchased', defaultValue: false) bool isPurchased,@JsonKey(name: 'is_free', defaultValue: false) bool isFree,@JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0) int storyCount,@JsonKey(name: 'rc_identifier') String? rcIdentifier
});




}
/// @nodoc
class _$CollectionCopyWithImpl<$Res>
    implements $CollectionCopyWith<$Res> {
  _$CollectionCopyWithImpl(this._self, this._then);

  final Collection _self;
  final $Res Function(Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleAr = null,Object? descriptionAr = freezed,Object? coverUrl = freezed,Object? price = freezed,Object? orderIndex = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isPurchased = null,Object? isFree = null,Object? storyCount = null,Object? rcIdentifier = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,storyCount: null == storyCount ? _self.storyCount : storyCount // ignore: cast_nullable_to_non_nullable
as int,rcIdentifier: freezed == rcIdentifier ? _self.rcIdentifier : rcIdentifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Collection].
extension CollectionPatterns on Collection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Collection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Collection value)  $default,){
final _that = this;
switch (_that) {
case _Collection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Collection value)?  $default,){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'description_ar')  String? descriptionAr, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'price')  double? price, @JsonKey(name: 'order_index')  int? orderIndex, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'is_purchased', defaultValue: false)  bool isPurchased, @JsonKey(name: 'is_free', defaultValue: false)  bool isFree, @JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0)  int storyCount, @JsonKey(name: 'rc_identifier')  String? rcIdentifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.titleAr,_that.descriptionAr,_that.coverUrl,_that.price,_that.orderIndex,_that.createdAt,_that.updatedAt,_that.isPurchased,_that.isFree,_that.storyCount,_that.rcIdentifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'description_ar')  String? descriptionAr, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'price')  double? price, @JsonKey(name: 'order_index')  int? orderIndex, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'is_purchased', defaultValue: false)  bool isPurchased, @JsonKey(name: 'is_free', defaultValue: false)  bool isFree, @JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0)  int storyCount, @JsonKey(name: 'rc_identifier')  String? rcIdentifier)  $default,) {final _that = this;
switch (_that) {
case _Collection():
return $default(_that.id,_that.titleAr,_that.descriptionAr,_that.coverUrl,_that.price,_that.orderIndex,_that.createdAt,_that.updatedAt,_that.isPurchased,_that.isFree,_that.storyCount,_that.rcIdentifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'title_ar')  String titleAr, @JsonKey(name: 'description_ar')  String? descriptionAr, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'price')  double? price, @JsonKey(name: 'order_index')  int? orderIndex, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'is_purchased', defaultValue: false)  bool isPurchased, @JsonKey(name: 'is_free', defaultValue: false)  bool isFree, @JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0)  int storyCount, @JsonKey(name: 'rc_identifier')  String? rcIdentifier)?  $default,) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.titleAr,_that.descriptionAr,_that.coverUrl,_that.price,_that.orderIndex,_that.createdAt,_that.updatedAt,_that.isPurchased,_that.isFree,_that.storyCount,_that.rcIdentifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Collection implements Collection {
  const _Collection({required this.id, @JsonKey(name: 'title_ar') required this.titleAr, @JsonKey(name: 'description_ar') this.descriptionAr, @JsonKey(name: 'cover_url') this.coverUrl, @JsonKey(name: 'price') this.price, @JsonKey(name: 'order_index') this.orderIndex, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'is_purchased', defaultValue: false) required this.isPurchased, @JsonKey(name: 'is_free', defaultValue: false) required this.isFree, @JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0) required this.storyCount, @JsonKey(name: 'rc_identifier') this.rcIdentifier});
  factory _Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'title_ar') final  String titleAr;
@override@JsonKey(name: 'description_ar') final  String? descriptionAr;
@override@JsonKey(name: 'cover_url') final  String? coverUrl;
@override@JsonKey(name: 'price') final  double? price;
@override@JsonKey(name: 'order_index') final  int? orderIndex;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'is_purchased', defaultValue: false) final  bool isPurchased;
@override@JsonKey(name: 'is_free', defaultValue: false) final  bool isFree;
@override@JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0) final  int storyCount;
@override@JsonKey(name: 'rc_identifier') final  String? rcIdentifier;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionCopyWith<_Collection> get copyWith => __$CollectionCopyWithImpl<_Collection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.price, price) || other.price == price)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.storyCount, storyCount) || other.storyCount == storyCount)&&(identical(other.rcIdentifier, rcIdentifier) || other.rcIdentifier == rcIdentifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,descriptionAr,coverUrl,price,orderIndex,createdAt,updatedAt,isPurchased,isFree,storyCount,rcIdentifier);

@override
String toString() {
  return 'Collection(id: $id, titleAr: $titleAr, descriptionAr: $descriptionAr, coverUrl: $coverUrl, price: $price, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt, isPurchased: $isPurchased, isFree: $isFree, storyCount: $storyCount, rcIdentifier: $rcIdentifier)';
}


}

/// @nodoc
abstract mixin class _$CollectionCopyWith<$Res> implements $CollectionCopyWith<$Res> {
  factory _$CollectionCopyWith(_Collection value, $Res Function(_Collection) _then) = __$CollectionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'title_ar') String titleAr,@JsonKey(name: 'description_ar') String? descriptionAr,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'price') double? price,@JsonKey(name: 'order_index') int? orderIndex,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'is_purchased', defaultValue: false) bool isPurchased,@JsonKey(name: 'is_free', defaultValue: false) bool isFree,@JsonKey(name: 'stories', fromJson: _storyCountFromJson, defaultValue: 0) int storyCount,@JsonKey(name: 'rc_identifier') String? rcIdentifier
});




}
/// @nodoc
class __$CollectionCopyWithImpl<$Res>
    implements _$CollectionCopyWith<$Res> {
  __$CollectionCopyWithImpl(this._self, this._then);

  final _Collection _self;
  final $Res Function(_Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleAr = null,Object? descriptionAr = freezed,Object? coverUrl = freezed,Object? price = freezed,Object? orderIndex = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isPurchased = null,Object? isFree = null,Object? storyCount = null,Object? rcIdentifier = freezed,}) {
  return _then(_Collection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,storyCount: null == storyCount ? _self.storyCount : storyCount // ignore: cast_nullable_to_non_nullable
as int,rcIdentifier: freezed == rcIdentifier ? _self.rcIdentifier : rcIdentifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
