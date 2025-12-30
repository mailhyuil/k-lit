# UTF-8 인코딩 수정

## 문제
아랍어 텍스트가 깨져서 표시됨 (예: `Ø§Ù...` 같은 이상한 문자)

## 원인
`StoryStorageService`에서 Storage 파일을 다운로드할 때 `String.fromCharCodes()`를 사용했는데, 이것은 Latin-1 인코딩을 사용하여 UTF-8 아랍어 텍스트를 제대로 처리하지 못함.

## 해결 방법
`dart:convert` 패키지의 `utf8.decode()` 및 `utf8.encode()` 사용

### 수정 전:
```dart
// ❌ 잘못된 방식 - Latin-1 인코딩
final metaString = String.fromCharCodes(metaBytes);
final bodyText = String.fromCharCodes(contentBytes);
final contentBytes = content.toText().codeUnits;
```

### 수정 후:
```dart
// ✅ 올바른 방식 - UTF-8 인코딩
import 'dart:convert';

final metaString = utf8.decode(metaBytes);
final bodyText = utf8.decode(contentBytes);
final contentBytes = utf8.encode(content.toText());
```

## 수정된 파일
- `lib/features/stories/services/story_storage_service.dart`
  - `downloadContent()` 메서드
  - `uploadContent()` 메서드
  - `downloadMeta()` 메서드

## 캐시 서비스는 문제 없음
`StoryCacheService`는 `File.readAsString()` 및 `writeAsString()`을 사용하는데, 이들은 기본적으로 UTF-8을 사용하므로 수정 불필요.

## 테스트 방법
1. Hot Restart (`R`)
2. Story 읽기 페이지 진입
3. 아랍어가 제대로 표시되는지 확인

## 예상 결과
```
يوم محظوظ  ← 올바른 아랍어
```

---

**수정 날짜:** 2025-12-30  
**상태:** ✅ 완료

