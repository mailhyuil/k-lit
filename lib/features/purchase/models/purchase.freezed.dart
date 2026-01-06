// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Purchase {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'collection_id') String get collectionId;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'transaction_id') String get transactionId;@JsonKey(name: 'source') String get source;@JsonKey(name: 'currency') String? get currency;@JsonKey(name: 'status') String get status;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseCopyWith<Purchase> get copyWith => _$PurchaseCopyWithImpl<Purchase>(this as Purchase, _$identity);

  /// Serializes this Purchase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.source, source) || other.source == source)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,collectionId,productId,transactionId,source,currency,status,createdAt);

@override
String toString() {
  return 'Purchase(id: $id, userId: $userId, collectionId: $collectionId, productId: $productId, transactionId: $transactionId, source: $source, currency: $currency, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseCopyWith<$Res>  {
  factory $PurchaseCopyWith(Purchase value, $Res Function(Purchase) _then) = _$PurchaseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'source') String source,@JsonKey(name: 'currency') String? currency,@JsonKey(name: 'status') String status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PurchaseCopyWithImpl<$Res>
    implements $PurchaseCopyWith<$Res> {
  _$PurchaseCopyWithImpl(this._self, this._then);

  final Purchase _self;
  final $Res Function(Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? collectionId = null,Object? productId = null,Object? transactionId = null,Object? source = null,Object? currency = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Purchase].
extension PurchasePatterns on Purchase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Purchase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Purchase value)  $default,){
final _that = this;
switch (_that) {
case _Purchase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Purchase value)?  $default,){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'source')  String source, @JsonKey(name: 'currency')  String? currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.userId,_that.collectionId,_that.productId,_that.transactionId,_that.source,_that.currency,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'source')  String source, @JsonKey(name: 'currency')  String? currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Purchase():
return $default(_that.id,_that.userId,_that.collectionId,_that.productId,_that.transactionId,_that.source,_that.currency,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'collection_id')  String collectionId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'source')  String source, @JsonKey(name: 'currency')  String? currency, @JsonKey(name: 'status')  String status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.userId,_that.collectionId,_that.productId,_that.transactionId,_that.source,_that.currency,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Purchase implements Purchase {
  const _Purchase({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'collection_id') required this.collectionId, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'transaction_id') required this.transactionId, @JsonKey(name: 'source') required this.source, @JsonKey(name: 'currency') this.currency, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'collection_id') final  String collectionId;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'transaction_id') final  String transactionId;
@override@JsonKey(name: 'source') final  String source;
@override@JsonKey(name: 'currency') final  String? currency;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCopyWith<_Purchase> get copyWith => __$PurchaseCopyWithImpl<_Purchase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.source, source) || other.source == source)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,collectionId,productId,transactionId,source,currency,status,createdAt);

@override
String toString() {
  return 'Purchase(id: $id, userId: $userId, collectionId: $collectionId, productId: $productId, transactionId: $transactionId, source: $source, currency: $currency, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCopyWith<$Res> implements $PurchaseCopyWith<$Res> {
  factory _$PurchaseCopyWith(_Purchase value, $Res Function(_Purchase) _then) = __$PurchaseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'collection_id') String collectionId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'source') String source,@JsonKey(name: 'currency') String? currency,@JsonKey(name: 'status') String status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PurchaseCopyWithImpl<$Res>
    implements _$PurchaseCopyWith<$Res> {
  __$PurchaseCopyWithImpl(this._self, this._then);

  final _Purchase _self;
  final $Res Function(_Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? collectionId = null,Object? productId = null,Object? transactionId = null,Object? source = null,Object? currency = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_Purchase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
