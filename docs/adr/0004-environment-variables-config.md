# ADR-0004: 환경 변수를 통한 설정 관리

## Status
Accepted

## Context
Supabase URL과 API 키 같은 민감한 정보를 코드에 하드코딩하면 보안 문제가 발생하고, 환경별(개발/스테이징/프로덕션) 설정 관리가 어려워진다. Flutter에서 환경 변수를 관리하는 방법으로 `flutter_dotenv`, `--dart-define`, 또는 빌드 설정 파일 등이 있다.

## Decision
`flutter_dotenv` 패키지를 사용하여 `.env` 파일로 환경 변수를 관리한다. `SUPABASE_URL`과 `SUPABASE_ANON_KEY`는 `.env` 파일에서 로드하며, 코드에는 포함하지 않는다.

## Consequences

### Pros
- 보안: 민감한 정보가 코드베이스에 포함되지 않음
- 환경별 설정: 개발/스테이징/프로덕션 환경별로 다른 `.env` 파일 사용 가능
- 간단한 구현: `flutter_dotenv`로 쉽게 구현 가능
- Git 제외: `.env` 파일을 `.gitignore`에 추가하여 버전 관리에서 제외 가능

### Cons
- 파일 관리: `.env` 파일을 각 환경에 수동으로 배포해야 함
- 타입 안전성 부족: 환경 변수 이름 오타 시 런타임 에러 발생 가능
- 빌드 시점 로드: 앱 시작 시 파일을 읽어야 하므로 초기화 시간 소요

## Notes
- `.env.example` 파일을 제공하여 필요한 환경 변수를 문서화한다.
- `.env` 파일은 `.gitignore`에 추가하여 버전 관리에서 제외한다.
- 환경 변수가 없을 경우 개발용 기본값을 사용하도록 처리한다.

