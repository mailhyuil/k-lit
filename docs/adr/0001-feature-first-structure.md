# ADR-0001: Feature-first 프로젝트 구조 채택

## Status
Accepted

## Context
프로젝트 초기 단계에서 코드베이스 구조를 결정해야 했다. Flutter 프로젝트는 전통적으로 레이어 기반 구조(layers-based, 예: `models/`, `views/`, `controllers/`)를 사용하지만, 기능이 증가하면서 관련 코드가 여러 디렉토리에 분산되어 유지보수가 어려워지는 문제가 있다.

## Decision
Feature-first 구조를 채택하여 각 기능을 독립적인 모듈로 구성한다. 각 feature는 자체 models, pages, providers, widgets을 포함한다.

```
lib/
├── features/
│   ├── auth/
│   │   ├── pages/
│   │   ├── providers/
│   │   └── widgets/
│   ├── books/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── providers/
│   │   └── widgets/
│   └── ...
└── core/
    └── config/
```

## Consequences

### Pros
- 기능별 코드 응집도 향상: 관련 코드가 한 곳에 모여 있어 이해하기 쉬움
- 기능 추가/제거 용이: 새 기능 추가 시 독립적인 디렉토리 생성
- 팀 협업 효율성: 기능별로 작업 분리 가능
- 코드 탐색 용이: 특정 기능 관련 코드를 빠르게 찾을 수 있음

### Cons
- 공통 코드 중복 가능성: 각 feature에서 유사한 유틸리티가 중복될 수 있음
- 공통 컴포넌트 관리 필요: `core/` 디렉토리에서 공통 코드를 명확히 관리해야 함
- 초기 구조 설계 중요: feature 간 의존성 관리가 중요함

## Notes
- 공통 코드는 `core/` 디렉토리에 배치하여 중복을 방지한다.
- Feature 간 의존성은 최소화하고, 필요한 경우 `core/`를 통해 공유한다.

