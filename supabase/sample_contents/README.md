# Story Contents - Supabase Storage 업로드 가이드

본문 콘텐츠를 Supabase Storage에 업로드하는 방법입니다.

---

## 📦 Storage 구조 (변경됨!)

```
story-contents/  (Bucket)
└── arabic/
    └── lucky_day/              ← 폴더 구조
        ├── content.txt         ← 본문 (순수 텍스트)
        └── _meta.json          ← 메타데이터 {"version": 1}
```

### 변경 이유

- ✅ 본문과 메타데이터 분리 → 관리 용이
- ✅ 순수 텍스트 파일 → 직접 읽기/편집 가능
- ✅ 폴더 구조 → 확장성 향상 (나중에 이미지 등 추가 가능)

---

## 📝 파일 형식

### 1. `content.txt` (본문)

```txt
في صباح بارد من شتاء سيول، استيقظ كيم تشون هو مبكرًا كالعادة...

[본문 내용...]

"يوم محظوظ"... همس بمرارة.
```

- **형식**: UTF-8 텍스트 파일
- **내용**: 순수 본문만
- **줄바꿈**: `\n` 사용

### 2. `_meta.json` (메타데이터)

```json
{
  "version": 1
}
```

- **형식**: JSON
- **필드**: `version` (정수)
- **용도**: 캐시 무효화, 버전 관리

---

## 🔒 접근 제어 정책 (RLS)

### 다운로드 권한

- ✅ **무료 작품** (`is_free = true`): 로그인한 모든 사용자
- ✅ **유료 작품**: 해당 컬렉션을 구매한 사용자만
- ❌ **미인증 사용자**: 접근 불가

### 업로드/수정/삭제

- ✅ **Admin 사용자만** 가능

---

## 📤 업로드 방법

### 방법 1: Supabase Dashboard (권장)

1. **Storage** → `story-contents` bucket 선택
2. `arabic/` 폴더로 이동 (없으면 생성)
3. **Create folder** → `lucky_day` 폴더 생성
4. `lucky_day/` 폴더로 이동
5. **Upload file**:
   - `content.txt` 업로드
   - `_meta.json` 업로드

### 방법 2: Supabase CLI

```bash
# 폴더 구조 생성 (자동)
supabase storage upload \
  story-contents/arabic/lucky_day/content.txt \
  --local supabase/sample_contents/arabic/lucky_day/content.txt

supabase storage upload \
  story-contents/arabic/lucky_day/_meta.json \
  --local supabase/sample_contents/arabic/lucky_day/_meta.json
```

### 방법 3: Flutter Admin 앱

```dart
final storageService = StoryStorageService();

final content = StoryContent.fromText(
  'في صباح بارد...',
  1, // version
);

await storageService.uploadContent(
  'arabic/lucky_day',  // 폴더 경로
  content,
);
// → arabic/lucky_day/content.txt
// → arabic/lucky_day/_meta.json
```

---

## 🗃️ DB 업데이트

파일을 업로드한 후, `stories` 테이블에 경로를 업데이트하세요:

```sql
UPDATE public.stories
SET
  content_url = 'arabic/lucky_day',  -- 폴더 경로 (파일명 없음!)
  content_version = 1,
  content_size_bytes = 1500
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
```

**⚠️ 중요**: `content_url`은 **폴더 경로**만 저장! 파일명 포함 X

---

## ✅ 다운로드 테스트

### 무료 작품 테스트

```dart
// 앱에서 테스트
final content = await ref.read(
  storyContentProvider('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa').future,
);
print(content.bodyAr);  // ✅ 성공!
print(content.version); // 1
```

### 유료 작품 테스트

```dart
// 로그인 없이 시도 → ❌ 에러
// 로그인 + 구매 안함 → ❌ 에러
// 로그인 + 구매 완료 → ✅ 성공!
```

---

## 🔍 디버깅

### 다운로드 실패 시 체크리스트

1. **Bucket이 Public인지 확인**

   - ❌ Public → 정책 무시됨
   - ✅ Private → 정책 적용됨

2. **폴더 구조가 올바른지 확인**

   ```
   ✅ arabic/lucky_day/content.txt
   ✅ arabic/lucky_day/_meta.json

   ❌ arabic/lucky_day.txt
   ❌ arabic/lucky_day/lucky_day.txt
   ```

3. **DB의 content_url 확인**

   ```sql
   SELECT content_url FROM public.stories
   WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

   -- 결과: 'arabic/lucky_day' (폴더 경로만!)
   ```

4. **Storage 정책이 적용되었는지 확인**

   ```sql
   SELECT * FROM pg_policies
   WHERE tablename = 'objects' AND schemaname = 'storage';
   ```

5. **파일이 실제로 존재하는지 확인**

   ```sql
   -- Storage 파일 목록 조회
   SELECT name FROM storage.objects
   WHERE bucket_id = 'story-contents'
   AND name LIKE 'arabic/lucky_day/%';

   -- 예상 결과:
   -- arabic/lucky_day/content.txt
   -- arabic/lucky_day/_meta.json
   ```

---

## 🚀 대량 업로드 스크립트

여러 작품을 한 번에 업로드할 때:

```bash
#!/bin/bash
# upload_all_stories.sh

for dir in supabase/sample_contents/arabic/*/; do
  story_name=$(basename "$dir")

  echo "Uploading $story_name..."

  # content.txt 업로드
  supabase storage upload \
    "story-contents/arabic/$story_name/content.txt" \
    --local "$dir/content.txt"

  # _meta.json 업로드
  supabase storage upload \
    "story-contents/arabic/$story_name/_meta.json" \
    --local "$dir/_meta.json"

  echo "✅ Uploaded: $story_name"
done

echo "🎉 All files uploaded!"
```

---

## 📋 체크리스트

업로드 완료 후 확인:

- [ ] Bucket `story-contents` 생성 (Private)
- [ ] Storage 정책 적용 (`storage_policies.sql`)
- [ ] 폴더 구조 생성 (`arabic/lucky_day/`)
- [ ] `content.txt` 업로드
- [ ] `_meta.json` 업로드
- [ ] `stories` 테이블 `content_url` 업데이트 (`arabic/lucky_day`)
- [ ] 무료 작품 다운로드 테스트
- [ ] 유료 작품 권한 체크 테스트
- [ ] 캐시 동작 확인

---

## 🎯 최종 플로우

```
1. 사용자가 Story 목록 확인
   ↓
2. Story 선택 → intro_ar, commentary_ar 즉시 표시 (DB에서)
   ↓
3. "본문 읽기" 버튼 클릭
   ↓
4. ⚠️ 권한 체크:
   - 무료 작품? → ✅ 다운로드
   - 유료 작품 + 구매함? → ✅ 다운로드
   - 유료 작품 + 구매 안함? → ❌ "구매 필요" 메시지
   ↓
5. Storage에서 다운로드:
   - arabic/lucky_day/_meta.json → version 확인
   - arabic/lucky_day/content.txt → body_ar 다운로드
   ↓
6. 로컬 캐시에 저장
   ↓
7. StoryReaderPage에 표시
```

---

## 🔗 관련 문서

- `supabase/storage_policies.sql`: Storage RLS 정책
- `supabase/init_schema.sql`: DB 스키마 + 샘플 데이터
- `docs/database-schema.md`: 전체 DB 설계
- `lib/features/stories/services/story_storage_service.dart`: Storage 서비스
- `lib/features/stories/providers/story_content_provider.dart`: 콘텐츠 프로바이더
- `lib/features/stories/models/story_content.dart`: 데이터 모델

---

완료! 🎉
