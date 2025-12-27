# Spec: Purchase (Book Purchase + Receipt Verification)

이 문서는 앱의 **책 구매 기능**(권당 구매, 구매 복원, 서버 검증, 권한 부여)을 정의한다.  
MVP에서는 **권당 구매(1 book = 1 purchase)** 를 기본으로 한다.

> 용어:
>
> - Store Purchase: App Store / Google Play 결제
> - Receipt/Token: 스토어가 제공하는 결제 증빙 데이터
> - Entitlement: 구매로 인해 “책 열람 권한”이 부여된 상태

---

## 0. Goal

- 사용자는 책을 **권당 구매**할 수 있어야 한다.
- 구매 성공 시, 서버(Supabase)에 구매 기록이 저장되어야 한다.
- 구매한 책은 My Page에 표시되며, Book Viewer에서 열람 가능해야 한다.
- 사용자는 구매를 복원(Restore)할 수 있어야 한다.
- 클라이언트 조작으로 유료 콘텐츠를 열람할 수 없도록 방지해야 한다.

---

## 1. Scope (MVP)

### Included

- In-App Purchase(IAP)로 책 1권 구매
- 구매 성공 후 영수증/토큰 서버 전달 및 검증
- `purchases` 테이블에 entitlement 기록
- 구매 복원 (Restore Purchases)
- 구매한 사용자만 `book_pages` 조회 가능 (RLS)

### Excluded (Later)

- 포인트 구매/광고 리워드
- 구독 모델
- 번들(패키지) 구매
- 쿠폰/프로모션
- 가족 공유 등 고급 구매 정책

---

## 2. Data Model (Supabase)

### purchases

- `user_id uuid` (FK → auth.users.id)
- `book_id uuid` (FK → books.id)
- `platform text` ("ios" | "android")
- `store_product_id text`
- `purchase_id text` (스토어 트랜잭션 ID, 가능하면 유니크)
- `purchased_at timestamptz`
- `raw_receipt jsonb` (선택: 디버깅/감사용, 민감 정보는 저장 정책 필요)
- PK: `(user_id, book_id)` 또는 별도 id + unique(user_id, book_id)

### purchase_events (optional but recommended)

- 구매/복원/검증 요청 이벤트 로그
- `id uuid pk`
- `user_id uuid`
- `book_id uuid`
- `event_type text` ("purchase" | "restore" | "verify_failed" ...)
- `created_at timestamptz`
- `payload jsonb`

---

## 3. Security & Authorization (Critical)

### RLS Rules

- `purchases`: 본인만 조회 가능
- `book_pages`: 구매한 사용자만 조회 가능

예: (개념)

- book_pages select allowed if exists purchases where purchases.book_id = book_pages.book_id and purchases.user_id = auth.uid()

### Client Trust Model

- 클라이언트에서 “구매했다고 표시”하는 것만으로 권한 부여 금지
- entitlement(구매 여부) 기록은 **서버 검증 후**에만 생성/갱신

---

## 4. Purchase Flow (Happy Path)

### 4.1 Purchase Start

1. 사용자가 Book Detail 또는 Book Viewer에서 “구매” 버튼 탭
2. 앱은 스토어 IAP 구매 플로우를 시작한다.

### 4.2 Purchase Success (Store)

1. 스토어에서 결제가 성공하면 앱은 `receipt/token`을 획득한다.
2. 앱은 즉시 서버에 검증 요청을 보낸다.

### 4.3 Server Verify & Grant

1. 서버(Edge Function)가 receipt/token을 스토어에 검증한다.
2. 검증 성공 시:
   - `purchases`에 upsert
   - 권한(entitlement) 부여 완료
3. 앱은 “구매 완료” 상태로 UI 업데이트

### 4.4 Content Access

- `purchases` 기록이 생긴 이후부터 Book Viewer에서 page 데이터 조회 가능
- `book_pages` RLS로 보호됨

---

## 5. Restore Purchases Flow

### 5.1 Restore Start

1. My Page 또는 Purchase 화면에서 “구매 복원” 버튼 탭
2. 앱은 스토어의 restore API를 호출한다.

### 5.2 Restore Results

- 스토어에서 반환된 각 구매 항목에 대해:
  - receipt/token 수집
  - 서버 검증 요청
  - purchases upsert

**Acceptance**

- 사용자가 앱을 재설치해도 구매했던 책을 다시 열람할 수 있어야 한다.

---

## 6. UI/UX Requirements

### 6.1 Purchase Entry Points

- Book List의 카드(선택)
- Book Viewer에서 권한 오류 발생 시 구매 유도
- My Page에서 미구매 도서 진입 시 구매 유도(선택)

### 6.2 Purchase Button States

- 기본: “구매”
- 구매 진행 중: “처리 중...” + disabled + loading
- 구매 완료: “구매 완료” 또는 버튼 숨김

### 6.3 Error Messages (User-friendly)

- 결제 취소: “결제가 취소되었습니다.”
- 네트워크 오류: “네트워크 상태를 확인해주세요.”
- 검증 실패: “결제 확인에 실패했습니다. 잠시 후 다시 시도해주세요.”
- 스토어 오류: “스토어 오류가 발생했습니다. 다시 시도해주세요.”

---

## 7. Backend Verification (Implementation Contract)

### 7.1 Edge Function: `verify_purchase`

**Input**

- `book_id`
- `platform` ("ios" | "android")
- `store_product_id`
- `receipt/token` (platform-specific)
- (optional) `purchase_id`

**Output**

- `{ ok: true }` on success
- `{ ok: false, reason: "..." }` on failure

**Rules**

- 요청자는 반드시 authenticated user여야 한다.
- 검증 성공 후에만 `purchases`를 기록한다.
- 같은 구매는 중복 저장되지 않아야 한다(idempotent).

### 7.2 Idempotency

- 동일한 receipt/token이 여러 번 와도 결과가 동일해야 한다.
- unique key로 `purchase_id` 또는 `receipt hash` 등을 사용 가능

---

## 8. Acceptance Criteria (MVP Checklist)

- [ ] 사용자가 책을 권당 구매할 수 있다.
- [ ] 구매 성공 후 서버 검증을 통해 purchases에 기록된다.
- [ ] 구매한 책은 My Page에 표시된다.
- [ ] 구매한 사용자만 book_pages를 조회할 수 있다(RLS).
- [ ] 구매 복원 기능이 동작한다.
- [ ] 결제 취소/실패 시 사용자 친화적 메시지가 표시된다.
- [ ] 클라이언트 조작만으로 유료 콘텐츠에 접근할 수 없다.

---

## 9. Non-Goals (Later)

- 포인트 시스템(광고/적립/차감)
- 번들/세트 구매
- 구독
- 프로모 코드/쿠폰
- 지역별 가격/세금/통화 정책 고도화
