/// Entitlement (권한) 모델
///
/// 사용자가 접근 가능한 컬렉션 목록
/// 구매, 프로모션, 구독 등 다양한 출처 지원
class Entitlement {
  final String id;
  final String userId;            // 사용자 ID
  final String collectionId;      // 컬렉션 ID
  final String source;            // 'purchase', 'promo', 'subscription'
  final String? productId;        // RevenueCat 또는 스토어 상품 ID
  final DateTime createdAt;
  final DateTime? expiresAt;      // NULL이면 영구 소유

  const Entitlement({
    required this.id,
    required this.userId,
    required this.collectionId,
    required this.source,
    this.productId,
    required this.createdAt,
    this.expiresAt,
  });

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Entitlement.fromMap(Map<String, dynamic> map) {
    return Entitlement(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      collectionId: map['collection_id'] as String,
      source: map['source'] as String? ?? 'purchase',
      productId: map['product_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
    );
  }

  /// 모델을 Map으로 변환 (Supabase INSERT/UPDATE 용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'collection_id': collectionId,
      'source': source,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// copyWith 메서드
  Entitlement copyWith({
    String? id,
    String? userId,
    String? collectionId,
    String? source,
    String? productId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Entitlement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionId: collectionId ?? this.collectionId,
      source: source ?? this.source,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// 권한이 아직 유효한지 확인
  bool get isActive {
    if (expiresAt == null) return true; // 영구 소유
    return expiresAt!.isAfter(DateTime.now());
  }

  /// 만료까지 남은 일수
  int? get daysUntilExpiration {
    if (expiresAt == null) return null; // 영구 소유
    final difference = expiresAt!.difference(DateTime.now());
    return difference.inDays;
  }

  /// 권한 유형 (한국어)
  String get sourceLabel {
    switch (source) {
      case 'purchase':
        return '구매';
      case 'promo':
        return '프로모션';
      case 'subscription':
        return '구독';
      default:
        return source;
    }
  }

  /// 만료 상태 문자열
  String get expirationStatus {
    if (expiresAt == null) {
      return '영구 소유';
    }
    
    if (!isActive) {
      return '만료됨';
    }
    
    final days = daysUntilExpiration!;
    if (days == 0) {
      return '오늘 만료';
    } else if (days == 1) {
      return '내일 만료';
    } else if (days <= 7) {
      return '$days일 후 만료';
    } else {
      return '${expiresAt!.year}-${expiresAt!.month}-${expiresAt!.day}까지';
    }
  }

  @override
  String toString() {
    return 'Entitlement(id: $id, collectionId: $collectionId, source: $source, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entitlement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

