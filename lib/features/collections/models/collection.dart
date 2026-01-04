/// Collection (컬렉션) 모델
///
/// 테마별로 묶인 작품 모음
/// 예: "현대 한국 단편", "전통 민담"
class Collection {
  final String id;
  final String titleAr; // 아랍어 제목
  final String? descriptionAr; // 아랍어 설명
  final String? coverPath; // Supabase Storage 경로
  final double price; // 'free', 'tier1', 'tier2', etc.
  final String? rcIdentifier; // RevenueCat 식별자
  final bool isFree; // 무료 여부
  final int orderIndex; // 정렬 순서
  final DateTime createdAt;
  final DateTime updatedAt;

  // 클라이언트 측 추가 필드
  final bool isPurchased; // 사용자가 구매했는지 여부 (client-side)
  final int storyCount; // 포함된 작품 수 (client-side)

  const Collection({
    required this.id,
    required this.titleAr,
    this.descriptionAr,
    this.coverPath,
    required this.price,
    required this.isFree,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isPurchased = false,
    this.storyCount = 0,
    this.rcIdentifier,
  });

  /// Supabase에서 가져온 데이터를 모델로 변환
  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] as String,
      titleAr: map['title_ar'] as String,
      descriptionAr: map['description_ar'] as String?,
      coverPath: map['cover_url'] as String?,
      price: map['price'] as double? ?? 0,
      isFree: map['is_free'] as bool? ?? false,
      orderIndex: map['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // 클라이언트 측 필드는 기본값 사용
      isPurchased: false,
      storyCount: map['stories']?[0]?['count'] as int? ?? 0,
      rcIdentifier: map['rc_identifier'] as String?,
    );
  }

  /// copyWith 메서드 (불변성 유지)
  Collection copyWith({
    String? id,
    String? titleAr,
    String? descriptionAr,
    String? coverPath,
    double? price,
    bool? isFree,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPurchased,
    int? storyCount,
    String? rcIdentifier,
  }) {
    return Collection(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      coverPath: coverPath ?? this.coverPath,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPurchased: isPurchased ?? this.isPurchased,
      storyCount: storyCount ?? this.storyCount,
      rcIdentifier: rcIdentifier ?? this.rcIdentifier,
    );
  }

  /// Cover 이미지 URL 가져오기 (Supabase Storage)
  String? get coverUrl {
    if (coverPath == null) return null;
    // TODO: Supabase Storage URL 생성
    // return SupabaseService.instance.client.storage.from('covers').getPublicUrl(coverPath!);
    return coverPath;
  }

  @override
  String toString() {
    return 'Collection(id: $id, titleAr: $titleAr, isFree: $isFree, isPurchased: $isPurchased)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Collection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
