# ADR-0003: Supabase를 백엔드로 채택

## Status
Accepted

## Context
백엔드 인프라를 구축하기 위해 자체 서버 구축, Firebase, AWS Amplify, Supabase 등 여러 옵션이 있었다. 프로젝트는 PostgreSQL 데이터베이스, 인증, 실시간 기능, Row Level Security(RLS)가 필요했다. 개발 속도와 유지보수 비용을 고려해야 했다.

## Decision
Supabase를 백엔드로 채택한다. PostgreSQL 데이터베이스, 인증, Row Level Security를 활용하여 백엔드 인프라를 구성한다.

## Consequences

### Pros
- PostgreSQL 기반: 강력한 관계형 데이터베이스 기능 활용 가능
- Row Level Security: 데이터베이스 레벨에서 보안 정책 적용 가능
- 인증 통합: 소셜 로그인(Google, Facebook, Apple) 지원
- 실시간 기능: WebSocket을 통한 실시간 데이터 동기화 가능
- 오픈소스: 자체 호스팅 옵션 제공
- 개발 속도: 빠른 프로토타이핑과 개발 가능

### Cons
- 벤더 종속성: Supabase 플랫폼에 의존
- 제한사항: Supabase의 제약사항 내에서만 작동
- 마이그레이션: 다른 백엔드로 전환 시 마이그레이션 필요
- 비용: 사용량 증가 시 비용 발생 가능

## Notes
- 클라이언트는 항상 RLS가 적용된 상태로 Supabase에 직접 접근한다.
- 환경 변수(`SUPABASE_URL`, `SUPABASE_ANON_KEY`)를 통해 설정을 관리한다.
- `supabase_flutter` 패키지를 사용하여 Flutter 앱과 통합한다.

