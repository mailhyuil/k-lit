# ADR-0002: Riverpod 3를 상태 관리 솔루션으로 채택

## Status
Accepted

## Context
Flutter 앱에서 상태 관리를 위해 Provider, Bloc, GetX, Riverpod 등 여러 옵션이 있다. 프로젝트는 복잡한 인증 상태 관리, 비동기 데이터 로딩, 그리고 여러 화면 간 상태 공유가 필요하다. 타입 안전성과 테스트 용이성, 그리고 Flutter와의 통합이 중요했다.

## Decision
Riverpod 3를 상태 관리 솔루션으로 채택한다. `NotifierProvider`와 `StreamProvider`를 사용하여 앱 전역 상태를 관리한다.

## Consequences

### Pros
- 컴파일 타임 타입 안전성: Provider 타입이 컴파일 시점에 검증됨
- 테스트 용이성: Provider를 쉽게 오버라이드하여 테스트 가능
- 성능 최적화: 필요한 위젯만 리빌드되도록 최적화됨
- 비동기 처리: `FutureProvider`, `StreamProvider`로 비동기 상태 관리 용이
- 의존성 주입: Provider를 통한 명시적 의존성 관리

### Cons
- 학습 곡선: Riverpod의 개념(Provider, Ref 등)을 이해해야 함
- 보일러플레이트: 간단한 상태에도 Provider 정의가 필요할 수 있음
- Riverpod 3 변경사항: 이전 버전과 API 차이로 인한 마이그레이션 필요

## Notes
- Riverpod 3의 `NotifierProvider`를 사용하여 상태 관리 로직을 구현한다.
- `StreamProvider`는 Supabase 인증 상태 변경을 감지하는 데 사용한다.
- Provider는 feature별로 분리하여 관리한다.

