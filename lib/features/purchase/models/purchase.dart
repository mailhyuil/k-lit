/// Purchase 모델
///
/// 구매 기록 (불변 로그)
class Purchase {
  final String id;
  final String userId;
  final String collectionId;
  final String productId;
  final String transactionId;
  final String source;
  final int? amountCents;
  final String? currency;
  final String status;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.userId,
    required this.collectionId,
    required this.productId,
    required this.transactionId,
    required this.source,
    this.amountCents,
    this.currency,
    required this.status,
    required this.createdAt,
  });

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      collectionId: map['collection_id'] as String,
      productId: map['product_id'] as String,
      transactionId: map['transaction_id'] as String,
      source: map['source'] as String,
      amountCents: map['amount_cents'] as int?,
      currency: map['currency'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 모델을 Map으로 변환 (Supabase INSERT/UPDATE 용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'collection_id': collectionId,
      'product_id': productId,
      'transaction_id': transactionId,
      'source': source,
      'amount_cents': amountCents,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
