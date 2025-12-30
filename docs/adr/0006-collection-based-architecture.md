# ADR 0006: Collection-Based Architecture

## Status
Accepted

## Context
기존 프로젝트는 단순한 "책 목록" 구조를 사용했습니다. 각 책이 독립적으로 존재하며, 사용자는 개별 책을 구매했습니다. 그러나 상용 앱으로 확장하면서 다음과 같은 요구사항이 생겼습니다:

1. **테마별 묶음 판매**: 관련된 작품들을 컬렉션으로 묶어 패키지로 판매
2. **무료 체험**: 일부 작품을 무료로 제공하여 사용자 유입 증대
3. **확장성**: 향후 구독 모델로 확장 가능한 구조
4. **컨텐츠 관리**: Admin이 컬렉션과 작품을 효율적으로 관리
5. **권한 관리**: 구매와 접근 권한을 명확히 분리

기존 구조의 문제점:
- 개별 책 판매는 수익 모델로 비효율적 (단가가 낮음)
- 테마별 묶음 판매가 불가능
- 무료 체험 로직이 복잡함
- 권한 관리가 구매 기록에 직접 의존 (유연성 부족)

## Decision
**컬렉션 중심 아키텍처**로 전환합니다.

### 핵심 개념

#### 1. Collections (컬렉션)
- 테마별로 묶인 작품 모음
- 예: "현대 한국 단편 소설", "전통 민담", "1950년대 문학"
- 각 컬렉션은 독립적인 구매 단위
- `is_free` 플래그로 무료/유료 구분

#### 2. Stories (작품)
- 각 컬렉션에 속한 개별 작품
- 제목, 서문(intro), 본문(body), 해설(commentary) 포함
- 개별 작품도 `is_free` 플래그 가능 (무료 체험용)

#### 3. Entitlements (권한)
- 사용자가 접근 가능한 컬렉션 목록
- 구매(purchase), 프로모션(promo), 구독(subscription) 등 다양한 출처 지원
- `expires_at` 필드로 유료 구독 지원 준비

#### 4. Purchases (구매 기록)
- 실제 결제 거래만 기록
- Entitlements와 분리하여 권한 관리 유연성 확보

### 데이터 흐름

```
사용자 구매 요청
    ↓
RevenueCat 결제 처리
    ↓
Edge Function (verify_purchase)
    ↓
purchases 테이블에 기록
    ↓
entitlements 테이블에 권한 부여
    ↓
RLS를 통해 stories 접근 허용
```

### RLS 정책

```sql
-- Stories: 무료 작품 OR 권한 보유 시 읽기 허용
CREATE POLICY "Allow read access to stories" 
    ON public.stories FOR SELECT 
    USING (
        is_free = true 
        OR EXISTS (
            SELECT 1 FROM public.entitlements 
            WHERE entitlements.user_id = auth.uid() 
            AND entitlements.collection_id = stories.collection_id
            AND (entitlements.expires_at IS NULL OR entitlements.expires_at > now())
        )
    );
```

### 비즈니스 모델

1. **무료 컬렉션** (is_free=true)
   - 모든 사용자 접근 가능
   - 앱 소개 및 사용자 유입 목적

2. **유료 컬렉션 + 무료 체험 작품**
   - 컬렉션 내 1-2개 작품을 무료로 제공
   - 사용자가 맛보기 후 구매 유도

3. **완전 유료 컬렉션**
   - 프리미엄 콘텐츠
   - 구매 후에만 접근 가능

### 향후 확장성

- **구독 모델**: `entitlements.expires_at` 사용
- **번들 패키지**: 여러 컬렉션을 묶어 할인 판매
- **시즌 패스**: 특정 기간 동안 모든 컬렉션 접근
- **오프라인 다운로드**: 권한 기반 로컬 캐싱

## Consequences

### Pros
- **수익 증대**: 패키지 판매로 단가 상승
- **사용자 경험**: 테마별로 정리된 콘텐츠
- **무료 체험**: 사용자 유입 증가
- **유연한 권한 관리**: 구매와 권한 분리
- **확장성**: 구독, 번들 등 다양한 모델 지원
- **Admin 효율성**: 테마별 컬렉션 관리

### Cons
- **초기 복잡도**: 단순 책 목록 대비 구조 복잡
- **마이그레이션**: 기존 코드 전면 수정 필요
- **데이터 모델**: 테이블 및 관계 증가
- **테스트**: 다양한 시나리오 테스트 필요

### Risks & Mitigation
- **Risk**: 컬렉션 구조가 사용자에게 복잡할 수 있음
  - **Mitigation**: 직관적인 UI/UX 설계, 명확한 네이밍
- **Risk**: 무료 체험 남용
  - **Mitigation**: 작품 수 제한, 분석을 통한 최적화
- **Risk**: RLS 성능 이슈
  - **Mitigation**: 적절한 인덱스, 쿼리 최적화

## Notes
- MVP에서는 컬렉션 단위 구매만 지원
- 구독 모델은 2단계에서 구현
- 현재 Mock 데이터: 무료 컬렉션 1개, 유료 컬렉션 1개, 총 작품 6개

## References
- [architecture.mdc](/docs/architecture.mdc)
- [database-schema.md](/docs/database-schema.md)
- ADR 0003: Supabase Backend
- ADR 0005: Book Viewer Implementation

