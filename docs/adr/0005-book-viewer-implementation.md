# ADR 0005: Book Viewer 구현

## 상태 (Status)

Accepted

## 컨텍스트 (Context)

사용자가 구매한 책을 페이지 단위로 읽을 수 있는 Book Viewer 기능이 필요했습니다. 아랍어(RTL) 지원과 직관적인 페이지 네비게이션이 핵심 요구사항이었습니다.

## 결정 (Decision)

Book Viewer 기능을 다음과 같이 구현하기로 결정했습니다:

1. **페이지 기반 읽기**: 서버에 미리 분할된 페이지 단위로 콘텐츠 제공
2. **터치 네비게이션**: 화면을 3영역(왼쪽 35%, 중앙 30%, 오른쪽 35%)으로 나눠 좌/우 터치로 페이지 이동
3. **RTL 지원**: `Directionality` 위젯을 사용한 아랍어 레이아웃
4. **폰트 조절**: 실시간 폰트 크기 조절 (0.5x ~ 2.0x)
5. **자동 진도 저장**: 페이지 이동 시 자동으로 읽기 진도 저장

## 구현 상세

### 데이터 모델
- `BookPage`: 책 페이지 데이터 (book_id, page_no, content)
- `ReadingProgress`: 읽기 진도 (user_id, book_id, last_page_no)

### 상태 관리
- `BookViewerController` (Riverpod Notifier): 페이지 상태, 폰트 크기, 로딩/에러 관리
- 페이지 로드, 네비게이션, 진도 저장 로직 포함

### UI 컴포넌트
- `BookViewerPage`: 메인 컨테이너
- `ReaderSurface`: 터치 영역과 페이지 콘텐츠 표시
- `PageContent`: RTL 텍스트 렌더링
- `BottomControls`: 폰트 조절 버튼과 페이지 표시
- `PageJumpDialog`: 특정 페이지로 이동

## 결과 (Consequences)

### 장점 (Pros)
- 직관적인 터치 기반 페이지 네비게이션
- RTL 레이아웃으로 아랍어 독서 경험 최적화
- 자동 진도 저장으로 편리한 이어 읽기
- Riverpod을 통한 명확한 상태 관리
- Supabase RLS를 통한 권한 기반 접근 제어

### 단점 (Cons)
- 페이지 단위 방식으로 스크롤 기반 읽기 불가능
- 각 페이지를 서버에서 개별 조회하므로 네트워크 의존적
- 오프라인 읽기 미지원 (MVP)

### 제약 사항
- MVP에서는 하이라이트, 메모, 검색 기능 제외
- 페이지는 서버에 미리 분할되어 있어야 함
- 동적 페이지네이션 미지원

## 참고 문서

- [Book Viewer 스펙](../specs/book-viewer.md)
- [데이터베이스 스키마](../database-schema.md)

