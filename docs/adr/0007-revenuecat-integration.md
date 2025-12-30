# ADR 0007: RevenueCat Integration for In-App Purchases

## Status
Accepted

## Context
상용 앱으로서 인앱 결제 시스템이 필요합니다. iOS App Store와 Google Play Store는 각각 다른 결제 API를 사용하며, 직접 연동 시 다음과 같은 문제가 있습니다:

### 직접 연동의 문제점
1. **플랫폼별 구현**: StoreKit 2 (iOS)와 Google Billing Library (Android)를 각각 구현해야 함
2. **영수증 검증**: 서버 사이드에서 Apple/Google 서버에 영수증 검증 필요
3. **구독 관리**: 갱신, 취소, 환불 등 복잡한 상태 관리
4. **크로스 플랫폼**: 사용자가 플랫폼을 바꿔도 구매 이력 유지 어려움
5. **분석**: 매출, 이탈률, LTV 등 수동으로 구축해야 함
6. **유지보수**: API 변경 시 지속적인 업데이트 필요

### 대안 평가

#### Option 1: 직접 연동 (StoreKit2 + Google Billing)
**Pros**:
- 수수료 없음
- 완전한 제어
- 빠른 응답 속도

**Cons**:
- 개발 시간 ↑↑ (2-3주 추가)
- 유지보수 부담
- 버그 리스크
- 분석 시스템 별도 구축

#### Option 2: RevenueCat
**Pros**:
- 통합 SDK (iOS + Android)
- 자동 영수증 검증
- 크로스 플랫폼 지원
- 실시간 분석 대시보드
- Webhook 지원
- 무료 티어 (월 $2,500 매출까지 무료)

**Cons**:
- 유료 티어 수수료 (매출의 1%)
- 외부 의존성
- 약간의 지연 (서버 통신)

#### Option 3: Adapty (RevenueCat 경쟁사)
**Pros**:
- RevenueCat과 유사한 기능
- A/B 테스팅 기능 강화

**Cons**:
- 커뮤니티 작은편
- 문서가 RevenueCat보다 부족

## Decision
**RevenueCat**을 결제 시스템으로 선택합니다.

### 선택 이유

1. **빠른 MVP 출시**
   - SDK 통합만으로 iOS/Android 동시 지원
   - 영수증 검증 자동화
   - 2-3일 내 결제 시스템 완성

2. **비용 효율성**
   - 월 $2,500 매출까지 무료
   - MVP 단계에서 비용 부담 없음
   - 성장 후 1% 수수료는 합리적

3. **개발자 경험**
   - 훌륭한 문서화
   - Flutter 공식 SDK (`purchases_flutter`)
   - 활발한 커뮤니티

4. **비즈니스 인사이트**
   - 실시간 매출 분석
   - 코호트 분석
   - 이탈률 추적
   - A/B 테스팅 (Enterprise)

5. **확장성**
   - 구독 관리 자동화
   - Webhook으로 Supabase 연동
   - 프로모션 코드 지원
   - Family Sharing 지원 (iOS)

### 아키텍처

```
Flutter App
    ↓
RevenueCat SDK
    ↓
App Store / Play Store
    ↓
RevenueCat Server (영수증 검증)
    ↓
Webhook → Supabase Edge Function
    ↓
entitlements 테이블 업데이트
```

### 구현 계획

#### 1. RevenueCat 설정
- 프로젝트 생성
- App Store Connect / Google Play Console 연동
- 상품 ID 등록 (예: `kr.co.app.collection_tier1`)

#### 2. Flutter SDK 통합
```yaml
dependencies:
  purchases_flutter: ^6.0.0
```

```dart
// 초기화
await Purchases.configure(
  PurchasesConfiguration('public_api_key'),
);

// 구매
try {
  CustomerInfo customerInfo = await Purchases.purchaseProduct(
    'kr.co.app.collection_tier1',
  );
  
  // entitlements 확인
  if (customerInfo.entitlements.all['pro']?.isActive == true) {
    // 권한 부여
  }
} catch (e) {
  // 에러 처리
}
```

#### 3. Supabase 연동
Edge Function `verify_purchase`:
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { event, api_version } = await req.json()
  
  // RevenueCat Webhook 처리
  if (event.type === 'INITIAL_PURCHASE') {
    const userId = event.app_user_id
    const productId = event.product_id
    const collectionId = productIdToCollectionId(productId)
    
    // entitlements 테이블 업데이트
    await supabase.from('entitlements').upsert({
      user_id: userId,
      collection_id: collectionId,
      source: 'purchase',
      product_id: productId,
    })
  }
  
  return new Response('OK', { status: 200 })
})
```

#### 4. 상품 설정

| Product ID | Collection | Price Tier |
|-----------|-----------|-----------|
| `kr.co.app.collection_free` | 무료 컬렉션 | 무료 |
| `kr.co.app.collection_classic` | 클래식 문학 | $2.99 |
| `kr.co.app.collection_modern` | 현대 문학 | $2.99 |
| `kr.co.app.subscription_monthly` | 월간 구독 | $4.99/월 |

### 보안

1. **서버 사이드 검증**
   - 영수증 검증은 RevenueCat 서버에서 처리
   - 클라이언트는 customerInfo만 확인
   - RLS로 서버 레벨 권한 체크

2. **User ID 매핑**
   - RevenueCat의 App User ID = Supabase auth.uid()
   - 크로스 플랫폼 지원

3. **Webhook 검증**
   - RevenueCat Webhook은 서명(signature) 검증
   - Edge Function에서 서명 확인

### 테스트

1. **Sandbox 테스트**
   - iOS: App Store Sandbox Account
   - Android: Google Play Test Track

2. **복원 테스트**
   ```dart
   CustomerInfo customerInfo = await Purchases.restorePurchases();
   ```

3. **플랫폼 간 이동 테스트**
   - iOS에서 구매 → Android에서 복원
   - 동일한 App User ID 사용

## Consequences

### Pros
- **개발 속도**: 2-3일 내 결제 시스템 완성
- **안정성**: 검증된 시스템, 99.9% 업타임
- **크로스 플랫폼**: iOS/Android 통합 관리
- **분석**: 실시간 매출 대시보드
- **확장성**: 구독, 프로모션 쉽게 추가
- **유지보수**: API 변경 대응 불필요

### Cons
- **외부 의존성**: RevenueCat 서비스 의존
- **수수료**: 월 $2,500 이후 1% 수수료
- **약간의 지연**: 서버 통신으로 0.5-1초 지연
- **커스터마이징 제한**: 일부 고급 기능은 제한적

### Risks & Mitigation
- **Risk**: RevenueCat 서비스 장애
  - **Mitigation**: 로컬 캐싱, 재시도 로직
- **Risk**: 수수료 부담 증가
  - **Mitigation**: 성장 후 직접 연동으로 마이그레이션 검토
- **Risk**: 데이터 소유권
  - **Mitigation**: 자체 purchases 테이블에도 기록

## Notes
- MVP에서는 컬렉션 단위 구매만 지원
- 구독 모델은 Phase 2
- 무료 티어 한도: 월 $2,500 매출 (약 월 850건 판매)

## References
- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [purchases_flutter Package](https://pub.dev/packages/purchases_flutter)
- ADR 0006: Collection-Based Architecture
- [architecture.mdc](/docs/architecture.mdc)

