# Spec: Auth - Login (Supabase)

이 문서는 앱의 로그인(회원가입/세션 포함) 기능을 구현하기 위한 스펙이다.  
인증은 **Supabase Auth**를 사용하며, Flutter에서는 `supabase_flutter`를 사용한다.

---

## 0. Goal

- 사용자는 앱에서 로그인/로그아웃 할 수 있어야 한다.
- 로그인 후 앱을 재실행해도 로그인 상태가 유지되어야 한다.
- 소셜 로그인(Google/Facebook/Apple)을 지원한다.
- 로그인 상태에 따라 접근 가능한 화면이 달라야 한다.
- 로그인 성공 시 사용자 프로필이 생성/갱신된다.

---

## 1. Supported Providers

### Required

- Google
- Facebook
- Apple

### Notes

- 각 Provider의 플랫폼별 설정(iOS/Android)과 콜백 URL은 별도 설정 문서에서 관리한다.
- MVP에서는 “이메일/비밀번호 로그인”은 선택 사항이며, 필요 시 추후 추가한다.

---

## 2. User Flows

### 2.1 App Launch → Session Restore

1. 앱 실행
2. Supabase 세션 존재 여부 확인
3. 세션이 있으면 로그인 상태로 전환 후 메인 화면(Book List) 진입
4. 세션이 없으면 Login 화면 진입

**Acceptance**

- 앱 재실행 시 재로그인 없이 바로 메인 화면으로 진입해야 한다.

---

### 2.2 Login (Google / Facebook / Apple)

1. Login 화면에서 Provider 버튼 탭
2. OAuth 인증 진행
3. 성공 시:
   - Supabase 세션 저장
   - `profiles` 생성 또는 업데이트
   - 메인 화면(Book List)로 이동
4. 실패 시:
   - 에러 메시지 표시
   - 사용자는 다시 시도 가능

**Acceptance**

- 로그인 성공 시 `auth.uid()`가 존재해야 한다.
- 로그인 성공 후 앱 내 API 호출은 인증된 상태여야 한다.

---

### 2.3 Logout

1. My Page(또는 Settings)에서 로그아웃 버튼 탭
2. 확인 다이얼로그 표시(선택)
3. 로그아웃 실행
4. 세션 제거 후 Login 화면으로 이동

**Acceptance**

- 로그아웃 이후에는 구매 목록/진도 같은 보호 리소스 접근이 불가능해야 한다.

---

## 3. Screens & UI Components

### 3.1 LoginPage

**Components**

- App Title / Logo
- 설명 텍스트(“한국 문학 아랍어 번역본을 읽어보세요” 등)
- Provider Buttons:
  - Continue with Google
  - Continue with Facebook
  - Continue with Apple
- Loading indicator (로그인 진행 중 버튼 비활성화)
- Error message area (Snackbar 또는 inline)

**UI Rules**

- 로그인 처리 중에는 중복 탭 방지(버튼 disabled)
- 에러는 사용자 친화적 문장으로 표시
- Material 3 가이드라인 준수

---

### 3.2 AuthGate (Routing Guard)

**역할**

- 앱 시작 시 로그인 여부에 따라 화면 라우팅을 결정한다.

**Behavior**

- `authenticated` → `BookListPage`
- `unauthenticated` → `LoginPage`

---

## 4. Data & Backend Behavior

### 4.1 Profiles Table Contract

- `profiles.id`는 `auth.users.id`(= `auth.uid()`)와 동일해야 한다.
- 로그인 성공 시 프로필이 없으면 생성하고, 있으면 필요한 필드를 갱신한다.

**Minimum fields**

- `id (uuid, pk)`
- `display_name (text, nullable)`
- `created_at (timestamp default now())`

**Profile Creation Timing**

- 옵션 A(권장): DB 트리거로 `auth.users` insert 시 자동 생성
- 옵션 B: 앱 로그인 성공 후 upsert

> MVP에서는 **옵션 B(앱에서 upsert)** 로 시작해도 되지만, 안정성을 위해 추후 트리거로 전환 가능.

---

### 4.2 RLS Requirements

- `profiles`는 본인만 조회/수정 가능
- `purchases`, `reading_progress` 등 보호 테이블 접근은 로그인 후에만 가능

---

## 5. Error Handling

### User-facing messages (예시)

- OAuth 취소: "로그인이 취소되었습니다."
- 네트워크 오류: "네트워크 상태를 확인해주세요."
- Provider 오류: "로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
- 알 수 없는 오류: "예기치 못한 오류가 발생했습니다."

**Rules**

- 개발용 에러 로그는 콘솔에 출력 가능하나, 사용자에게 raw error를 그대로 노출하지 않는다.
- 로그인 실패 후에도 앱이 크래시하면 안 된다.

---

## 6. State Management (Riverpod)

### Required Providers (concept)

- `authStateProvider`: 현재 세션/유저 상태 스트림
- `currentUserProvider`: `User?`
- `authControllerProvider`: 로그인/로그아웃 액션

**Rules**

- UI는 auth 상태에 따라 자동 갱신되어야 한다.
- 중복 로그인 요청 방지(loading state)

---

## 7. Analytics (Optional / Later)

- login_success(provider)
- login_failure(provider, reason)
- logout

(MVP에서는 생략 가능)

---

## 8. Non-goals (MVP)

- 이메일/비밀번호 회원가입/로그인(필요 시 별도 스펙으로 추가)
- 계정 삭제
- 비밀번호 재설정
- 다중 계정 전환

---

## 9. Acceptance Criteria (MVP Checklist)

- [ ] 앱 실행 시 세션이 있으면 자동 로그인 된다.
- [ ] 로그인 화면에서 Google/Facebook/Apple 로그인 가능.
- [ ] 로그인 성공 시 Book List로 이동한다.
- [ ] 로그인 성공 시 profiles가 생성 또는 업데이트된다.
- [ ] 로그아웃 후 Login 화면으로 이동하며 보호 리소스 접근이 차단된다.
- [ ] 로그인 실패/취소 시 사용자 친화적 에러 메시지가 표시된다.
