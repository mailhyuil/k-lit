// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Purchase _$PurchaseFromJson(Map<String, dynamic> json) => _Purchase(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  collectionId: json['collection_id'] as String,
  productId: json['product_id'] as String,
  transactionId: json['transaction_id'] as String,
  source: json['source'] as String,
  currency: json['currency'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PurchaseToJson(_Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'collection_id': instance.collectionId,
  'product_id': instance.productId,
  'transaction_id': instance.transactionId,
  'source': instance.source,
  'currency': instance.currency,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
};
