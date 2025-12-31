# Spec: stories

이 문서는 앱의 **stories 화면(책 목록)** 기능을 구현하기 위한 스펙이다.  
사용자는 이 화면에서 읽을 수 있는 책들을 탐색하고, 책을 선택해 Book Viewer로 이동한다.

---

## 0. Goal

- 사용자는 앱에 등록된 책 목록을 볼 수 있어야 한다.
- 각 책의 기본 정보를 한눈에 파악할 수 있어야 한다.
- 책을 선택하면 Book Viewer 페이지로 이동한다.
- 로그인 상태에 따라 “구매 여부”가 반영된 UI를 제공한다.

---

## 1. Entry & Navigation

### Entry Points

- 로그인 성공 후 기본 진입 화면
- 앱 재실행 시 세션 복원 후 기본 진입 화면
- Book Viewer / My Page에서 뒤로 이동 시

### Navigation

- 책 카드 탭 → Book Viewer
- AppBar 액션 → My Page

---

## 2. Screen Layout

```txt
┌───────────────────────────────┐
│ App Bar │
├───────────────────────────────┤
│ stories (Grid / List) │
│ │
│ [Cover] [Title] │
│ [Cover] [Title] │
│ │
└───────────────────────────────┘
```

---

## 3. Components

### 3.1 BookListPage (Container)

**Responsibilities**

- 책 목록 로딩/에러 상태 관리
- 로그인 사용자 정보 연동
- BookCard 리스트 렌더링
- 페이지 이동 처리

**State**

- `books: List<Book>`
- `purchasedBookIds: Set<BookId>`
- `isLoading: bool`
- `error: String?`

---

### 3.2 AppBar

**Components**

- Title: 앱 이름 또는 “Books”
- Actions:
  - My Page 아이콘 버튼

**Behavior**

- My Page 버튼 탭 → My Page 화면으로 이동

---

### 3.3 BookListView

**Type**

- MVP: `ListView` 또는 `GridView` 중 택 1
- 추천:
  - 세로 스크롤 `GridView` (2-column, cover 중심)

**Rules**

- 스크롤 성능 고려 (lazy loading)
- 빈 리스트일 경우 Empty State 표시

---

### 3.4 BookCard

**Inputs**

- `bookId`
- `title`
- `author`
- `coverUrl`
- `isPurchased: bool`

**UI Elements**

- Book Cover Image
- Book Title (1~2줄, ellipsis)
- Author (선택)
- Purchase Badge (선택)
  - “Purchased” / “Owned” / 아이콘

**Interaction**

- Card 탭:
  - 구매한 책 → Book Viewer로 이동
  - 구매하지 않은 책 → Book Viewer 또는 구매 유도(후속 단계)

**MVP Rule**

- MVP에서는 구매 여부와 상관없이 Book Viewer 진입 가능  
  (실제 접근 제어는 Book Viewer + RLS에서 처리)

---

### 3.5 Empty State

**Conditions**

- 책 데이터가 0개일 때

**UI**

- 아이콘
- 메시지: “등록된 책이 없습니다.”

---

### 3.6 Loading / Error State

#### Loading

- 최초 진입 시 중앙 로딩 인디케이터
- Pull-to-refresh 시 상단 인디케이터

#### Error

- 네트워크/권한 오류 시:
  - 에러 메시지
  - “다시 시도” 버튼

---

## 4. Data & Backend Behavior

### 4.1 Fetch Books

- Table: `books`
- Order: `created_at DESC` (또는 지정된 정렬 기준)

### 4.2 Fetch Purchases (로그인 상태일 때)

- Table: `purchases`
- Filter: `user_id = auth.uid()`
- 결과를 `Set<bookId>` 형태로 보관

> 구매 여부는 UI 표시용이며, 실제 접근 권한은 RLS로 보장한다.

---

## 5. State Management (Riverpod)

### Required Providers (concept)

- `bookListProvider`
- `purchaseListProvider`
- `bookListControllerProvider`

**Rules**

- 로그인 상태 변경 시 목록 자동 갱신
- 에러 발생 시 UI에 반영
- 불필요한 재요청 방지

---

## 6. UX Rules

- 커버 이미지 로딩 실패 시 placeholder 표시
- 스크롤 위치는 화면 전환 후 복원하지 않아도 됨 (MVP)
- 탭 반응은 즉각적이어야 한다

---

## 7. Accessibility

- 카드 터치 영역 최소 44dp 이상
- 이미지에 semantic label 제공(선택)
- 텍스트 대비 충분히 확보

---

## 8. Non-goals (MVP)

- 검색
- 필터/정렬 UI
- 카테고리/태그
- 추천 알고리즘
- 무한 스크롤(페이지네이션)

---

## 9. Acceptance Criteria (MVP Checklist)

- [ ] 로그인 후 stories 화면으로 진입한다.
- [ ] 책 목록이 정상적으로 표시된다.
- [ ] 각 책 카드에 표지와 제목이 보인다.
- [ ] 구매한 책은 구매 상태가 UI에 반영된다.
- [ ] 구매가 안된 책은 구매 페이지로 이동하여 구매를 진행한다.
- [ ] 책을 탭하면 Book Viewer로 이동한다.
- [ ] 로딩/에러 상태가 사용자에게 명확히 표시된다.
