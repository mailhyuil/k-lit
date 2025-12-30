# Spec: Search

이 문서는 **Search(검색)** 기능을 구현하기 위한 스펙이다.  
Search는 등록된 책을 검색하여 결과가 있으면 하단에 **Grid 형태로 책 목록**을 보여준다.  
검색 결과가 없으면 “검색 결과 없음” 메시지를 보여준다.

---

## 0. Goal

- 사용자는 책 제목/저자(최소 제목)로 책을 검색할 수 있어야 한다.
- 검색 결과는 Grid로 표시되어야 한다.
- 결과가 없을 때는 명확한 Empty State를 보여준다.
- 로딩/에러 상태를 사용자에게 보여준다.
- 검색은 입력 변화에 따라 자연스럽게 동작해야 한다(디바운스 적용).

---

## 1. Entry & Navigation

### Entry Points

- Book List 상단(SearchBar 또는 아이콘)에서 진입
- (선택) 독립 페이지(SearchPage)로 진입하거나, Book List 내 인라인 검색으로 제공

### Navigation

- 검색 결과의 BookCard 탭 → Book Viewer로 이동
- 뒤로가기 → 이전 화면(Book List)로 복귀
- (선택) 검색창의 clear 버튼 → 검색어 초기화 및 기본 상태로 복귀

---

## 2. Screen Layout

MVP 기준, Search는 다음 구조를 가진다.

```txt
┌───────────────────────────────┐
│ App Bar (optional) │
├───────────────────────────────┤
│ Search Input │
│ [🔍 검색어 입력 ... (x)] │
├───────────────────────────────┤
│ Results Area │
│ - Loading / Error / Empty │
│ - Grid of BookCards │
└───────────────────────────────┘
```

---

## 3. Components

### 3.1 SearchPage (Container)

**Responsibilities**

- 검색어 입력 상태 관리
- 검색 API 호출 및 결과 관리
- 로딩/에러/empty 상태 관리
- 결과 리스트 렌더링
- BookCard 탭 시 라우팅

**State**

- `query: String`
- `results: List<Book>`
- `status: SearchStatus` (idle | loading | success | empty | error)
- `errorMessage: String?`

---

### 3.2 SearchInput (SearchBar)

**UI**

- leading icon: search icon
- hint text: “책 제목 또는 저자 검색”
- trailing icon: clear(x) (query가 비어있지 않을 때만 표시)

**Behavior**

- 입력 시 디바운스 후 검색 실행
- clear(x) 클릭 시:
  - query 초기화
  - status = idle
  - 결과 영역은 기본 상태(가이드 텍스트 또는 빈 상태)로 전환

**Keyboard**

- text input
- submit(enter) 시 즉시 검색 실행 (디바운스 무시 가능)

---

### 3.3 ResultsArea

SearchStatus에 따라 아래 중 하나를 표시한다.

#### Idle State (query가 비어있거나 첫 진입)

- 안내 문구 표시:
  - “검색어를 입력하세요.”
- 결과 Grid는 표시하지 않음

#### Loading State

- 로딩 인디케이터 표시
- 기존 결과가 있다면(옵션):
  - 결과 유지 + 상단에 얇은 로딩 표시(UX 개선)

#### Success State (results > 0)

- Grid로 결과 표시 (BookGrid)

#### Empty State (results == 0)

- 메시지 표시:
  - “검색 결과가 없습니다.”
- (선택) “다른 검색어로 시도해보세요.” 안내

#### Error State

- 에러 메시지 표시
- “다시 시도” 버튼 제공

---

### 3.4 BookGrid

**Type**

- GridView (2-column 권장)
- spacing: 12~16dp
- aspect ratio는 커버 비율에 맞게 조정

**Items**

- BookCard 재사용(= Book List와 동일 컴포넌트)

---

### 3.5 BookCard (재사용)

**Inputs**

- `bookId`
- `title`
- `author`
- `coverUrl`
- (optional) `isPurchased`

**Interaction**

- 탭 → Book Viewer로 이동

---

## 4. Search Behavior & Rules

### 4.1 Search Fields

MVP에서는 최소 다음 필드를 검색 대상에 포함한다.

- title (필수)
- author (권장)
- (선택) description

### 4.2 Matching Rule

- 대소문자 무시
- 부분 문자열 매칭(contains)
- 공백은 trimming 후 처리
- query 길이 기준:
  - `query.length < 2` 이면 검색하지 않고 idle(권장)
  - 또는 바로 검색하되 결과가 과도하면 디바운스 강화

### 4.3 Debounce

- 디바운스 시간: 300ms (권장 250~400ms)
- 입력 중 연속 타이핑 시 요청을 합친다.
- 새로운 query로 검색이 시작되면 이전 요청의 결과는 무시한다(최신 query 우선).

---

## 5. Data & Backend Behavior (Supabase)

### 5.1 Fetch Strategy (MVP)

- Table: `books`
- Query 예시(개념):
  - `ilike('title', '%query%')` OR `ilike('author', '%query%')`

> 참고: OR 조건이 필요하므로 Supabase query builder의 `or(...)`를 활용한다.

### 5.2 Sorting

- 기본 정렬: relevance가 없으므로 단순 정렬 사용
  - 예: `created_at DESC` 또는 `title ASC`
- (선택) title 매칭 우선 정렬은 2차 개선에서 고려

### 5.3 Permissions

- books는 기본적으로 읽기 가능해야 한다.
- 구매 여부 표시가 필요하면:
  - 로그인 상태일 때 `purchases`를 조회해 `isPurchased`를 계산한다(옵션)

---

## 6. State Management (Riverpod)

### Suggested Providers (concept)

- `searchQueryProvider` (String)
- `searchResultsProvider` (AsyncValue<List<Book>> or custom state)
- `searchControllerProvider` (debounce, fetch orchestration)

**Rules**

- query 변경 → debounce → fetch
- error 발생 → 상태 유지 + 재시도 가능
- query가 비면 idle로 전환

---

## 7. Loading / Error Handling

### Loading

- 최초 로딩: 중앙 인디케이터
- 연속 검색: 기존 결과 유지 + 상단 로딩(옵션)

### Error Cases

- 네트워크 오류
- Supabase 오류
- 권한 오류(일반적으로 books는 공개이므로 드묾)

**User Messages**

- 네트워크: “네트워크 상태를 확인해주세요.”
- 일반 오류: “검색 중 오류가 발생했습니다.”

---

## 8. Accessibility & UX

- SearchBar는 최소 터치 영역 44dp
- clear 버튼에 semantics label 제공(선택)
- 키보드 submit으로 검색 가능
- 다크 모드(Material 3) 지원

---

## 9. Non-Goals (MVP)

- 검색 히스토리 저장
- 자동완성/추천 검색어
- 고급 필터(카테고리/가격/구매 여부)
- 전문 검색(FTS) 및 relevance ranking
- 오프라인 검색

---

## 10. Acceptance Criteria (MVP Checklist)

- [ ] 사용자가 검색어를 입력하면 300ms 디바운스 후 검색된다.
- [ ] 검색은 최소 title(권장: author 포함)을 대상으로 한다.
- [ ] 검색 결과가 있으면 하단에 Grid 형태로 책 목록이 표시된다.
- [ ] 검색 결과가 없으면 “검색 결과가 없습니다.” 메시지가 표시된다.
- [ ] 로딩 상태가 표시된다.
- [ ] 오류 발생 시 에러 메시지와 “다시 시도” 버튼이 표시된다.
- [ ] 검색 결과의 책을 탭하면 Book Viewer로 이동한다.
- [ ] 검색어 clear 시 기본 상태로 돌아간다.
