import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

@freezed
abstract class Purchase with _$Purchase {
  const factory Purchase({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'source') required String source,
    @JsonKey(name: 'currency') String? currency,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Purchase;

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Purchase.fromJson(Map<String, dynamic> map) =>
      _$PurchaseFromJson(map);
}
