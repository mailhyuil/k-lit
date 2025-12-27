# Spec: My Page

이 문서는 **My Page(내 페이지)** 기능을 구현하기 위한 스펙이다.  
My Page는 사용자의 계정 정보와 “구매한 책”을 중심으로 구성되며, 구매한 책을 선택하면 Book Viewer로 이동한다.

---

## 0. Goal

- 로그인한 사용자는 My Page에서 **구매한 책 목록**을 확인할 수 있어야 한다.
- 구매한 책을 선택하면 Book Viewer로 이동해야 한다.
- 사용자는 로그아웃 할 수 있어야 한다.
- 로그인하지 않은 사용자는 My Page에 접근할 수 없다(AuthGate로 차단).

---

## 1. Entry & Navigation

### Entry Points

- Book List AppBar의 My Page 아이콘 버튼

### Exit

- AppBar back 버튼 → Book List로 이동

---

## 2. Screen Layout

```txt
┌───────────────────────────────┐
│ Top App Bar │
├───────────────────────────────┤
│ Profile Summary (optional) │
├───────────────────────────────┤
│ Purchased Books List │
│ - BookCard ... │
│ - BookCard ... │
├───────────────────────────────┤
│ Logout Button │
└───────────────────────────────┘
```

---

## 3. Components

### 3.1 MyPage (Container)

**Responsibilities**

- 사용자 로그인 상태 확인(AuthGate 이후이므로 인증 상태 보장)
- 프로필 요약 표시(선택)
- 구매한 책 목록 로딩 및 표시
- 로그아웃 처리
- 에러/로딩 상태 처리

**State**

- `profile: Profile?`
- `purchasedBooks: List<Book>`
- `isLoading: bool`
- `error: String?`

---

### 3.2 TopAppBar

**UI**

- Leading: Back 버튼
- Title: “My Page” (또는 아랍어 로컬라이징)
- Actions: 없음 (MVP)

**Behavior**

- Back 버튼 탭 → Book List로 이동

---

### 3.3 ProfileSummary (Optional, MVP에서는 간단)

**Inputs**

- `displayName` (없으면 기본값 표시)
- `email` (표시 여부 선택)

**UI**

- 사용자 이름(또는 “User”)
- (선택) 이메일

**Rules**

- 프로필 로딩 실패가 My Page 전체를 막지 않도록 한다.
- displayName이 없으면 “사용자” 혹은 기본 문구를 표시한다.

---

### 3.4 PurchasedBookList

**Type**

- MVP: `ListView` 또는 `GridView`
- Book List와 동일한 카드 컴포넌트를 재사용 권장

**Empty State**

- 구매한 책이 0개일 때:
  - 메시지: “구매한 책이 없습니다.”
  - (선택) “책 보러 가기” 버튼 → Book List로 이동

---

### 3.5 PurchasedBookCard

**Inputs**

- `bookId`
- `title`
- `author`
- `coverUrl`

**Interaction**

- 탭하면 Book Viewer로 이동

**Rule**

- My Page의 리스트는 “구매한 책만” 포함되므로 purchased badge는 생략 가능

---

### 3.6 LogoutSection

**UI**

- 로그아웃 버튼(Outlined 또는 Text Button)

**Behavior**

1. 로그아웃 버튼 탭
2. 확인 다이얼로그 표시(권장)
   - Title: “로그아웃”
   - Message: “정말 로그아웃할까요?”
   - Cancel / Logout
3. Logout 선택 시:
   - `supabase.auth.signOut()`
   - LoginPage로 이동 (navigation stack 정리)

**Rules**

- 로그아웃 중 버튼 비활성화
- 실패 시 에러 메시지 표시

---

## 4. Data & Backend Behavior

### 4.1 Fetch Profile (Optional)

- Table: `profiles`
- Query: `id = auth.uid()`

> MVP에서 프로필 표시는 최소화 가능

---

### 4.2 Fetch Purchased Books

**Source**

- Table: `purchases` + `books`

**Behavior**

- `purchases`에서 `user_id = auth.uid()`로 구매 목록 조회
- 해당 `book_id` 목록을 이용해 `books`에서 상세 정보 조회
- 정렬: `purchased_at DESC` (권장)

**RLS**

- purchases는 본인만 조회 가능
- books는 공개 조회 가능(또는 유료 정책에 따라 공개)

---

## 5. Loading & Error States

### Loading

- 최초 진입 시 로딩 표시
- 구매 목록 로딩 실패 시에도 화면이 크래시하면 안 됨

### Error

- 네트워크 오류
- 인증 토큰 만료(세션 만료) 등

**UI**

- 에러 메시지 표시
- “다시 시도” 버튼 제공

**Session Expired Rule**

- 세션이 만료되어 인증이 풀린 경우:
  - AuthGate가 LoginPage로 라우팅하도록 한다.

---

## 6. State Management (Riverpod)

### Required Providers (concept)

- `profileProvider`
- `purchasedBooksProvider`
- `authControllerProvider` (logout)

**Rules**

- 로그아웃 성공 시 모든 사용자 관련 provider는 초기화되어야 한다.
- My Page는 로그인된 사용자 기준으로만 동작한다.

---

## 7. Accessibility & UX Rules

- 리스트 터치 영역 최소 44dp
- 커버 이미지 로딩 실패 시 placeholder
- 다크 모드(Material 3) 지원

---

## 8. Non-Goals (MVP)

- 프로필 수정
- 구매 내역 상세(영수증/결제일 상세)
- 계정 삭제
- 고객센터/문의 기능
- 언어 변경 UI (추후 추가 가능)

---

## 9. Acceptance Criteria (MVP Checklist)

- [ ] 로그인한 사용자만 My Page에 접근 가능하다.
- [ ] My Page에서 구매한 책 목록을 볼 수 있다.
- [ ] 구매한 책을 탭하면 Book Viewer로 이동한다.
- [ ] 구매한 책이 없으면 Empty State가 표시된다.
- [ ] 로그아웃 버튼이 동작하며, 로그아웃 후 LoginPage로 이동한다.
- [ ] 로딩/에러 상태가 사용자에게 명확히 표시된다.
