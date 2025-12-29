# 한국 문학 (Korean Literature)

한국 문학 작품을 아랍어로 번역한 책을 읽을 수 있는 Flutter 앱입니다.

## 프로젝트 구조

```
lib/
├── core/              # 공통 설정 및 유틸리티
│   └── config/        # Supabase 설정
├── features/          # 기능별 모듈
│   ├── auth/          # 인증 기능
│   │   ├── pages/     # 로그인 페이지
│   │   ├── providers/ # 인증 상태 관리
│   │   └── widgets/   # AuthGate 위젯
│   └── books/         # 책 목록 기능
│       ├── models/    # Book 모델
│       ├── pages/     # 책 목록 페이지
│       ├── providers/ # 책 목록 상태 관리
│       └── widgets/   # BookCard 위젯
└── main.dart          # 앱 진입점
```

## 시작하기

### 1. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

`.env.example` 파일을 참고하세요.

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. 앱 실행

```bash
flutter run
```

## 주요 기능

### 구현 완료
- ✅ Feature-first 프로젝트 구조
- ✅ Riverpod 3를 사용한 상태 관리
- ✅ Supabase 초기화 및 환경 변수 설정
- ✅ AuthGate: 인증 상태에 따른 라우팅
- ✅ LoginPage: Google/Facebook/Apple 로그인 버튼 (스텁)
- ✅ BookListPage: 로딩/에러/빈 상태 처리

### 향후 구현 예정
- ⏳ 실제 소셜 로그인 구현
- ⏳ 책 목록 데이터 연동
- ⏳ Book Viewer
- ⏳ 구매 기능
- ⏳ My Page

## 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Riverpod 3**: 상태 관리
- **Supabase**: 백엔드 (Auth, Database)
- **Material 3**: 디자인 시스템

## 개발 규칙

- Feature-first 구조 유지
- Riverpod을 사용한 상태 관리
- Material 3 가이드라인 준수
- 코드는 간결하고 명확하게 작성
