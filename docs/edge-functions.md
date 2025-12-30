# Supabase Edge Functions

Korean Essential Literature 앱의 Supabase Edge Functions 설계 문서입니다.

## 개요

Edge Functions는 서버 사이드 로직을 처리하며, 주요 역할은 다음과 같습니다:
1. **결제 검증**: RevenueCat Webhook 처리 및 영수증 검증
2. **권한 관리**: Entitlements 테이블 업데이트 (클라이언트 직접 접근 불가)
3. **구매 복원**: 사용자 구매 이력 복원
4. **이벤트 로깅**: 중요 이벤트 기록 (선택 사항)

---

## 1. verify_purchase

RevenueCat Webhook을 처리하여 구매를 검증하고 entitlements를 부여합니다.

### 엔드포인트
```
POST https://<project-id>.supabase.co/functions/v1/verify_purchase
```

### 인증
RevenueCat Webhook은 서명(signature)으로 검증합니다.

### Request Body (RevenueCat Webhook)
```json
{
  "api_version": "1.0",
  "event": {
    "aliases": ["$RCAnonymousID:abc123"],
    "app_id": "abc123",
    "app_user_id": "550e8400-e29b-41d4-a716-446655440000",
    "commission_percentage": 0.3,
    "country_code": "US",
    "currency": "USD",
    "entitlement_id": null,
    "entitlement_ids": ["pro"],
    "environment": "PRODUCTION",
    "event_timestamp_ms": 1644347820312,
    "expiration_at_ms": null,
    "id": "evt_abc123",
    "is_family_share": false,
    "is_trial_conversion": false,
    "offer_code": null,
    "original_app_user_id": "550e8400-e29b-41d4-a716-446655440000",
    "original_transaction_id": "123456789",
    "period_type": "NORMAL",
    "presented_offering_id": null,
    "price": 2.99,
    "price_in_purchased_currency": 2.99,
    "product_id": "kr.co.app.collection_classic",
    "purchased_at_ms": 1644347820312,
    "store": "APP_STORE",
    "subscriber_attributes": {},
    "takehome_percentage": 0.7,
    "tax_percentage": 0.0,
    "transaction_id": "987654321",
    "type": "INITIAL_PURCHASE"
  }
}
```

### 구현 예시

```typescript
// supabase/functions/verify_purchase/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createHmac } from 'https://deno.land/std@0.168.0/node/crypto.ts'

const REVENUECAT_WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  try {
    // 1. Webhook 서명 검증
    const signature = req.headers.get('X-RevenueCat-Signature')
    const body = await req.text()
    const expectedSignature = createHmac('sha256', REVENUECAT_WEBHOOK_SECRET)
      .update(body)
      .digest('hex')

    if (signature !== expectedSignature) {
      return new Response('Invalid signature', { status: 401 })
    }

    // 2. Event 파싱
    const { event } = JSON.parse(body)
    
    // 3. Supabase 클라이언트 생성 (service_role 사용)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // 4. 이벤트 타입별 처리
    switch (event.type) {
      case 'INITIAL_PURCHASE':
      case 'NON_RENEWING_PURCHASE':
        await handlePurchase(supabase, event)
        break
      
      case 'RENEWAL':
        await handleRenewal(supabase, event)
        break
      
      case 'CANCELLATION':
        await handleCancellation(supabase, event)
        break
      
      case 'EXPIRATION':
        await handleExpiration(supabase, event)
        break
    }

    return new Response('OK', { status: 200 })
  } catch (error) {
    console.error('Error processing webhook:', error)
    return new Response('Internal Server Error', { status: 500 })
  }
})

async function handlePurchase(supabase: any, event: any) {
  const userId = event.app_user_id
  const productId = event.product_id
  const collectionId = productIdToCollectionId(productId)
  
  // purchases 테이블에 기록
  await supabase.from('purchases').insert({
    user_id: userId,
    platform: event.store.toLowerCase(),
    product_id: productId,
    rc_transaction_id: event.transaction_id,
    raw_payload_json: event,
    status: 'verified',
    verified_at: new Date().toISOString(),
  })

  // entitlements 테이블에 권한 부여
  await supabase.from('entitlements').upsert({
    user_id: userId,
    collection_id: collectionId,
    source: 'purchase',
    product_id: productId,
    expires_at: event.expiration_at_ms 
      ? new Date(event.expiration_at_ms).toISOString() 
      : null,
  }, {
    onConflict: 'user_id,collection_id'
  })
}

async function handleRenewal(supabase: any, event: any) {
  // 구독 갱신 처리
  const userId = event.app_user_id
  const collectionId = productIdToCollectionId(event.product_id)
  
  await supabase.from('entitlements')
    .update({
      expires_at: new Date(event.expiration_at_ms).toISOString(),
    })
    .match({ user_id: userId, collection_id: collectionId })
}

async function handleCancellation(supabase: any, event: any) {
  // 구독 취소 시 만료일은 유지 (만료까지 접근 가능)
  console.log('Subscription cancelled:', event.app_user_id)
}

async function handleExpiration(supabase: any, event: any) {
  // 만료 시 자동으로 RLS가 차단 (expires_at > now() 조건)
  console.log('Subscription expired:', event.app_user_id)
}

function productIdToCollectionId(productId: string): string {
  // 상품 ID → 컬렉션 ID 매핑
  const mapping: Record<string, string> = {
    'kr.co.app.collection_classic': '22222222-2222-2222-2222-222222222222',
    'kr.co.app.collection_modern': '33333333-3333-3333-3333-333333333333',
    // ...추가 매핑
  }
  return mapping[productId] || ''
}
```

### RevenueCat 설정

RevenueCat Dashboard에서 Webhook URL 등록:
```
https://<project-id>.supabase.co/functions/v1/verify_purchase
```

---

## 2. restore_purchases

사용자의 구매 이력을 복원합니다.

### 엔드포인트
```
POST https://<project-id>.supabase.co/functions/v1/restore_purchases
```

### 인증
Supabase Auth JWT 토큰 필요

### Request Body
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### Response
```json
{
  "success": true,
  "restored_count": 2,
  "entitlements": [
    {
      "collection_id": "22222222-2222-2222-2222-222222222222",
      "source": "purchase",
      "expires_at": null
    },
    {
      "collection_id": "33333333-3333-3333-3333-333333333333",
      "source": "purchase",
      "expires_at": "2024-12-31T23:59:59Z"
    }
  ]
}
```

### 구현 예시

```typescript
// supabase/functions/restore_purchases/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // 1. 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    // 2. 사용자 확인
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response('Unauthorized', { status: 401 })
    }

    // 3. RevenueCat에서 구매 이력 조회
    const rcResponse = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${user.id}`,
      {
        headers: {
          'Authorization': `Bearer ${Deno.env.get('REVENUECAT_API_KEY')}`,
          'X-Platform': 'ios', // or 'android'
        },
      }
    )

    const rcData = await rcResponse.json()
    
    // 4. Entitlements 복원
    const serviceRoleSupabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const restoredEntitlements = []
    
    for (const [entitlementId, entitlement] of Object.entries(rcData.subscriber.entitlements)) {
      if (entitlement.expires_date) {
        const expiresAt = new Date(entitlement.expires_date)
        if (expiresAt < new Date()) continue // 만료된 권한 제외
      }

      const collectionId = entitlementIdToCollectionId(entitlementId)
      
      await serviceRoleSupabase.from('entitlements').upsert({
        user_id: user.id,
        collection_id: collectionId,
        source: 'purchase',
        product_id: entitlement.product_identifier,
        expires_at: entitlement.expires_date || null,
      }, {
        onConflict: 'user_id,collection_id'
      })

      restoredEntitlements.push({
        collection_id: collectionId,
        source: 'purchase',
        expires_at: entitlement.expires_date || null,
      })
    }

    return new Response(JSON.stringify({
      success: true,
      restored_count: restoredEntitlements.length,
      entitlements: restoredEntitlements,
    }), {
      headers: { 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('Error restoring purchases:', error)
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

function entitlementIdToCollectionId(entitlementId: string): string {
  // Entitlement ID → Collection ID 매핑
  const mapping: Record<string, string> = {
    'pro': '22222222-2222-2222-2222-222222222222',
    'premium': '33333333-3333-3333-3333-333333333333',
  }
  return mapping[entitlementId] || ''
}
```

---

## 3. log_event (선택 사항)

앱 이벤트를 로깅합니다. (분석용)

### 엔드포인트
```
POST https://<project-id>.supabase.co/functions/v1/log_event
```

### 인증
선택 사항 (게스트 이벤트도 로깅)

### Request Body
```json
{
  "event_name": "view_collection",
  "props": {
    "collection_id": "22222222-2222-2222-2222-222222222222",
    "source": "home_screen"
  }
}
```

### 구현 예시

```typescript
// supabase/functions/log_event/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { event_name, props } = await req.json()
    
    // 사용자 ID 추출 (있으면)
    let userId = null
    const authHeader = req.headers.get('Authorization')
    if (authHeader) {
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_ANON_KEY')!,
        { global: { headers: { Authorization: authHeader } } }
      )
      const { data: { user } } = await supabase.auth.getUser()
      userId = user?.id
    }

    // 이벤트 로깅
    const serviceRoleSupabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    await serviceRoleSupabase.from('events').insert({
      user_id: userId,
      event_name,
      props_json: props,
    })

    return new Response('OK', { status: 200 })
  } catch (error) {
    console.error('Error logging event:', error)
    return new Response('Internal Server Error', { status: 500 })
  }
})
```

---

## 배포

### 로컬 개발
```bash
# Supabase CLI 설치
brew install supabase/tap/supabase

# 프로젝트 초기화
supabase init

# Edge Functions 생성
supabase functions new verify_purchase
supabase functions new restore_purchases
supabase functions new log_event

# 로컬 실행
supabase functions serve
```

### 프로덕션 배포
```bash
# 배포
supabase functions deploy verify_purchase
supabase functions deploy restore_purchases
supabase functions deploy log_event

# 환경 변수 설정
supabase secrets set REVENUECAT_WEBHOOK_SECRET=your_secret
supabase secrets set REVENUECAT_API_KEY=your_api_key
```

---

## 테스트

### verify_purchase 테스트
```bash
curl -X POST https://<project-id>.supabase.co/functions/v1/verify_purchase \
  -H "Content-Type: application/json" \
  -H "X-RevenueCat-Signature: <signature>" \
  -d @test_webhook.json
```

### restore_purchases 테스트
```bash
curl -X POST https://<project-id>.supabase.co/functions/v1/restore_purchases \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"550e8400-e29b-41d4-a716-446655440000"}'
```

---

## 보안 체크리스트

- [ ] Webhook 서명 검증 구현
- [ ] Service Role Key 안전하게 관리 (환경 변수)
- [ ] JWT 토큰 검증
- [ ] Rate Limiting 설정 (Supabase 대시보드)
- [ ] 에러 로깅 및 모니터링
- [ ] 타임아웃 설정 (기본 30초)

