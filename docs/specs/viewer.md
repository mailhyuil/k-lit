# Spec: Viewer

이 문서는 **Viewer(책 읽기 화면)** 기능의 UI, 동작, 데이터 흐름을 정의한다.  
MVP 기준으로, 페이지는 서버(Supabase)에 **미리 분할된 페이지 단위**로 저장되어 있다.

---

## 0. Goal

- 사용자는 책을 페이지 단위로 읽을 수 있어야 한다.
- 이전/다음 페이지 이동이 직관적이어야 한다.
- 텍스트 크기 조절이 가능해야 한다.
- 마지막으로 읽은 페이지를 저장하고, 다시 열면 이어서 읽는다.
- 아랍어(RTL) 읽기 경험을 보장한다.

---

## 1. Entry & Navigation

### Entry Points

- Book List에서 책 선택
- My Page에서 구매한 책 선택

### Exit

- 상단 AppBar의 “Back” 버튼 → Book List로 이동

---

## 2. Screen Layout

Viewer는 3개의 주요 영역으로 구성된다.

```txt
┌───────────────────────────────┐
│ Top App Bar │
├───────────────────────────────┤
│ │
│ Reader Surface (Page Area) │
│ │
├───────────────────────────────┤
│ Bottom Controls │
└───────────────────────────────┘
```

---

## 3. Components

### 3.1 BookViewerPage (Container)

**Responsibilities**

- 현재 페이지 상태 관리
- 페이지 데이터 로딩
- 페이지 이동 처리
- 읽기 진도 저장
- 에러/로딩 처리

**Inputs**

- `bookId: String`

**State**

- `currentPageNo: int`
- `fontScale: double` (기본값: 1.0)
- `isLoading: bool`
- `error: String?`
- `totalPages: int`

---

### 3.2 TopAppBar

**UI**

- Leading: Back 버튼 (아이콘)
- Title: 책 제목 (1줄, ellipsis)
- Actions: 없음 (MVP)

**Behavior**

- Back 버튼 클릭 시 Book List로 이동

---

### 3.3 ReaderSurface

**역할**

- 현재 페이지의 텍스트 표시
- 화면 터치로 이전/다음 페이지 이동

#### Interaction Zones

- 화면을 가로 기준으로 3영역으로 나눈다:
  - **왼쪽 35%** → 이전 페이지
  - **오른쪽 35%** → 다음 페이지
  - **중앙 30%** → 아무 동작 없음 (또는 컨트롤 토글, 옵션)

> RTL 환경이지만 **요구사항에 따라**
>
> - 왼쪽 = 이전
> - 오른쪽 = 다음  
>   을 유지한다.

#### Edge Rules

- 첫 페이지에서 이전 요청 → 무시
- 마지막 페이지에서 다음 요청 → 무시

---

### 3.4 PageContent

**Inputs**

- `content: String`
- `pageNo: int`
- `fontScale: double`

**Rendering Rules**

- Directionality: RTL
- TextAlign: start
- 아랍어 지원 폰트 사용
- 줄 간격(line height): 약 1.4
- 좌우 패딩: 20~24dp
- 상하 패딩: 16~20dp

---

### 3.5 BottomControls

**UI Elements**

- Font Decrease 버튼 (A-)
- Font Increase 버튼 (A+)
- Page Indicator (예: `12 / 240`)

**Behavior**

- A- 클릭 → `fontScale -= 0.1` (최소값 제한)
- A+ 클릭 → `fontScale += 0.1` (최대값 제한)
- Page Indicator 클릭 → Page Jump Dialog 표시

**Rules**

- 폰트 크기 변경 시 페이지 번호는 유지된다.
- 폰트 크기는 로컬 저장 가능(SharedPreferences 등).

---

### 3.6 PageJumpDialog

**UI**

- Title: “페이지 이동”
- 숫자 입력 필드
- Helper Text: `1 ~ totalPages`
- Buttons: Cancel / Go

**Validation**

- 숫자만 입력 가능
- 범위 밖 숫자는 에러 표시
- 유효한 입력 시 해당 페이지로 이동

---

## 4. Data & Backend Behavior

### 4.1 Page Fetch

- Table: `book_pages`
- Query:
  - `book_id = :bookId`
  - `page_no = :currentPageNo`

**Optimization (Optional)**

- 현재 페이지 로드 후
  - 이전 페이지와 다음 페이지를 프리패치

---

### 4.2 Reading Progress Save

**Trigger**

- 페이지 이동 완료 후

**Action**

- `reading_progress` 테이블 upsert:
  - `user_id`
  - `book_id`
  - `last_page_no = currentPageNo`
  - `updated_at = now()`

**Rules**

- 저장 실패 시 UI 흐름은 막지 않는다.
- 다음 페이지 이동 시 재시도 가능.

---

## 5. Security

- `book_pages` 조회는 RLS에 의해 제한된다.
- 구매하지 않은 사용자는 페이지 데이터를 조회할 수 없다.
- Viewer 진입 자체는 가능하되,
  실제 페이지 데이터 접근은 Supabase에서 차단된다.

---

## 6. Loading & Error States

### Loading

- 최초 진입 시 전체 화면 로딩 표시
- 페이지 이동 시:
  - 가능하면 즉시 전환
  - 불가하면 ReaderSurface에 로딩 표시

### Error

- 네트워크 오류
- 권한 오류(구매하지 않음)
- 데이터 없음

**UI**

- 에러 메시지
- “다시 시도” 버튼

---

## 7. Accessibility & UX Rules

- 터치 영역 최소 44dp
- 폰트 확대 시 텍스트 잘림 방지
- 다크 모드(Material 3) 지원

---

## 8. Non-Goals (MVP)

- 스크롤 기반 리더
- 동적 페이지네이션
- 하이라이트/메모
- 검색
- 오프라인 다운로드

---

## 9. Acceptance Criteria (MVP Checklist)

- [ ] 책을 열면 마지막으로 읽은 페이지부터 표시된다.
- [ ] 왼쪽 터치 시 이전 페이지로 이동한다.
- [ ] 오른쪽 터치 시 다음 페이지로 이동한다.
- [ ] 텍스트 크기를 조절할 수 있다.
- [ ] 페이지 번호를 눌러 특정 페이지로 이동할 수 있다.
- [ ] 페이지 이동 시 읽기 진도가 저장된다.
- [ ] 아랍어 RTL 레이아웃이 정상적으로 적용된다.
