# 🔄 Handoff Document - Korean Literature App

**From:** Cursor/Claude (Vibe Coding)  
**To:** Gemini CLI  
**Date:** 2025-12-30  
**Status:** ✅ Database & Storage Setup Complete, App Running

---

## 📋 프로젝트 개요

**프로젝트명:** Korean Literature App (한국 문학 아랍어 번역 앱)  
**기술 스택:**
- Frontend: Flutter (Dart)
- Backend: Supabase (PostgreSQL + Storage)
- State Management: Riverpod 3
- Payments: RevenueCat
- Authentication: Supabase Auth (Google OAuth)

**목표:** 한국 문학 작품을 아랍어로 번역하여 제공하는 앱

---

## ✅ 완료된 작업

### 1. **Database 설정** ✅
- [x] 6개 테이블 생성 (profiles, collections, stories, entitlements, purchases, events)
- [x] RLS 정책 적용 (모든 테이블)
- [x] 인덱스 생성 (17개)
- [x] 트리거 설정 (auto-update, auto-create)
- [x] 샘플 데이터 삽입 (1 collection, 1 story)
- [x] 파일: `supabase/schema.sql` (473 lines)

### 2. **Storage 설정** ✅
- [x] story-contents 버킷 생성 (Private)
- [x] Storage RLS 정책 4개 적용
  - SELECT: 무료 or 구매한 사용자만
  - INSERT/UPDATE/DELETE: Admin만
- [x] 파일: `supabase/storage_policies.sql` (187 lines)

### 3. **Storage 구조 변경** ✅
**폴더 기반 구조로 변경:**
```
story-contents/
└── arabic/
    └── lucky_day/              ← 폴더
        ├── content.txt         ← 본문 (순수 텍스트)
        └── _meta.json          ← {"version": 1}
```

**변경 이유:**
- 본문과 메타데이터 분리
- 순수 텍스트 파일로 관리 용이
- 확장성 향상 (나중에 이미지 추가 가능)

### 4. **Flutter 코드 업데이트** ✅

#### **Models:**
- `lib/features/stories/models/story_content.dart`
  - `StoryContent`: 본문 모델
  - `StoryMeta`: 메타데이터 모델
  - `fromText()`, `toText()` 메서드

#### **Services:**
- `lib/features/stories/services/story_storage_service.dart`
  - Storage 다운로드/업로드 서비스
  - `content.txt` + `_meta.json` 처리
  
- `lib/features/stories/services/story_cache_service.dart`
  - 로컬 캐싱 (LRU 방식)
  - 100MB 제한, 30일 만료

#### **Providers:**
- `lib/features/stories/providers/story_content_provider.dart`
  - Content 로딩 (캐시 우선 → Storage 다운로드)
  - 권한 체크 (무료 or Entitlement)

### 5. **App 실행 확인** ✅
```bash
flutter run -d macos
# ✓ Built successfully
# ✓ Supabase init completed
# ✓ RevenueCat 초기화 완료
```

### 6. **Mock → Supabase 전환** ✅
- [x] `collection_provider.dart`: Supabase 연동 완료
- [x] `story_provider.dart`: Supabase 연동 완료
- [x] 모든 데이터 요청이 실제 DB에서 가져옴
- [x] RLS 정책 자동 적용됨

---

## 🔄 현재 상태

### **Database:**
```sql
-- 테이블: 6개 (profiles, collections, stories, entitlements, purchases, events)
-- RLS: 활성화 (모든 테이블)
-- 샘플 데이터: 
--   - 1 collection: "قصص كورية كلاسيكية" (무료)
--   - 1 story: "يوم محظوظ" (Lucky Day, 무료)
```

### **Storage:**
```
story-contents/ (Private 버킷)
├── RLS 정책: 4개 적용
└── 예상 파일 위치:
    └── arabic/lucky_day/
        ├── content.txt   (업로드 필요!)
        └── _meta.json    (업로드 필요!)
```

### **App:**
```
- 실행: ✅ 성공
- Mock → Supabase: ✅ 완료
- 로그인: ⏳ 테스트 필요
- Collection 목록: ⏳ 테스트 필요 (실제 DB 연동)
- Story 읽기: ⏳ 테스트 필요 (Storage 다운로드)
```

---

## 🎯 다음 단계 (우선순위 순)

### **1. Storage 파일 업로드** 🔥 (최우선)

**방법:**
```
Dashboard → Storage → story-contents
→ 폴더 생성: arabic/lucky_day/
→ 업로드: content.txt, _meta.json
```

**파일 위치:**
```
supabase/sample_contents/arabic/lucky_day/
├── content.txt   ← 이 파일 업로드
└── _meta.json    ← 이 파일 업로드
```

### **2. App 기능 테스트**

**테스트 순서:**
1. 로그인 (Google OAuth)
2. Collection 목록 표시
3. Collection → Story 목록
4. Story 읽기 (Storage 다운로드 확인)

**예상 로그:**
```dart
📥 Downloading content from Storage: arabic/lucky_day
✅ Meta downloaded: version 1
✅ Content downloaded: 1500 bytes
✅ Content loaded and cached
```

### **3. ~~Mock 데이터 vs DB 데이터 정리~~ ✅ 완료!**

**변경 완료:**
- ✅ `collection_provider.dart`: Mock 데이터 삭제, Supabase 연동 완료
- ✅ `story_provider.dart`: Mock 데이터 삭제, Supabase 연동 완료
- ✅ 모든 Provider가 실제 Supabase DB 사용

**파일:**
- `lib/features/stories/providers/story_provider.dart` ✅
- `lib/features/collections/providers/collection_provider.dart` ✅

### **4. 추가 작품 등록**

현재 1개 작품만 있음. 더 추가 필요:
```sql
-- supabase/schema.sql에 INSERT 문 추가
-- Storage에 파일 업로드
```

---

## 📂 주요 파일 위치

### **Backend (Supabase):**
```
supabase/
├── schema.sql              ← 통합 DB 스키마 (473 lines)
├── storage_policies.sql    ← Storage RLS 정책 (187 lines)
├── init_schema.sql         ← 이전 버전 (사용 안함)
└── sample_contents/
    └── arabic/lucky_day/
        ├── content.txt
        └── _meta.json
```

### **Frontend (Flutter):**
```
lib/
├── main.dart                          ← 앱 진입점
├── core/
│   └── config/
│       ├── supabase_client.dart       ← Supabase 초기화
│       └── revenuecat_config.dart     ← RevenueCat 초기화
├── features/
│   ├── auth/                          ← 로그인
│   ├── collections/                   ← 컬렉션 목록
│   │   ├── models/collection.dart
│   │   ├── providers/collection_provider.dart
│   │   └── pages/collection_list_page.dart
│   ├── stories/                       ← 작품 관리
│   │   ├── models/
│   │   │   ├── story.dart
│   │   │   └── story_content.dart     ← ⭐ Storage 모델
│   │   ├── services/
│   │   │   ├── story_storage_service.dart  ← ⭐ Storage 다운로드
│   │   │   └── story_cache_service.dart    ← ⭐ 로컬 캐싱
│   │   ├── providers/
│   │   │   ├── story_provider.dart         ← Mock 데이터
│   │   │   └── story_content_provider.dart ← ⭐ Content 로딩
│   │   └── pages/
│   │       └── story_reader_page.dart      ← 읽기 페이지
│   ├── entitlements/                  ← 구매 권한
│   └── purchase/                      ← RevenueCat 구매
```

### **Documentation:**
```
docs/
├── architecture.mdc           ← 전체 아키텍처
├── database-schema.md         ← DB 스키마 상세 (600 lines)
├── setup-revenuecat.md        ← RevenueCat 설정 가이드
├── edge-functions.md          ← Edge Functions 설계
└── adr/                       ← Architecture Decision Records
    ├── 0006-collection-based-architecture.md
    └── 0007-revenuecat-integration.md
```

---

## ⚠️ 중요 사항

### **1. Storage 경로 규칙**

**DB에 저장하는 경로:**
```sql
content_url = 'arabic/lucky_day'  ← 폴더 경로만! (파일명 X)
```

**Storage 실제 파일:**
```
arabic/lucky_day/content.txt
arabic/lucky_day/_meta.json
```

**Flutter에서 다운로드:**
```dart
final contentUrl = story.contentUrl; // 'arabic/lucky_day'
await storageService.downloadContent(contentUrl);
// → 내부적으로 content.txt, _meta.json 다운로드
```

### **2. RLS 정책 중요!**

**Storage Bucket이 Private이어야 함:**
```
✅ Private → RLS 정책 적용됨
❌ Public → RLS 정책 무시됨 (누구나 다운로드 가능)
```

**정책 확인 쿼리:**
```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects';
```

### **3. ~~Mock 데이터 주의~~ ✅ 완료!**

**Mock 데이터 완전 제거:**
```dart
// ✅ 모든 Provider가 Supabase에서 데이터 가져옴
// ✅ contentUrl은 DB의 샘플 데이터 사용 ('arabic/lucky_day')
// ✅ RLS 정책 자동 적용
```

### **4. 환경 변수 (.env)**

**.env 파일에 필요한 값:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
REVENUECAT_API_KEY_ANDROID=...
REVENUECAT_API_KEY_IOS=...
```

---

## 🐛 트러블슈팅

### **문제 1: "Story not found"**
```
원인: DB에 샘플 데이터가 없음
해결: schema.sql의 샘플 데이터 확인
     DB에 최소 1개 collection + 1개 story 필요
     story ID: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
```

### **문제 2: "403 Forbidden" (Storage)**
```
원인: Storage 정책 미적용 또는 Bucket이 Public
해결: 
1. Bucket이 Private인지 확인
2. Storage 정책 4개 모두 생성되었는지 확인
```

### **문제 3: "File not found" (Storage)**
```
원인: Storage에 파일이 실제로 없음
해결:
1. Dashboard → Storage → story-contents → arabic/lucky_day/
2. content.txt, _meta.json 확인
```

### **문제 4: "Entitlement denied"**
```
원인: 무료 작품인데 is_free = false로 설정
해결:
UPDATE public.stories 
SET is_free = true 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
```

---

## 🧪 테스트 방법

### **1. Database 확인**
```sql
-- 테이블 목록
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- 샘플 데이터 확인
SELECT c.title_ar, s.title_ar, s.content_url, s.is_free
FROM collections c
LEFT JOIN stories s ON s.collection_id = c.id;

-- 예상 결과:
-- قصص كورية كلاسيكية | يوم محظوظ | arabic/lucky_day | true
```

### **2. Storage 정책 확인**
```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects';

-- 예상: 4개 정책
-- Allow download if free or purchased | SELECT
-- Allow admin to upload | INSERT
-- Allow admin to update | UPDATE
-- Allow admin to delete | DELETE
```

### **3. App 로그 확인**
```bash
# 터미널에서 실행
flutter run -d macos

# 예상 로그:
# ✓ Supabase init completed
# ✓ RevenueCat 초기화 완료
# 📥 Downloading content from Storage: arabic/lucky_day
# ✅ Content downloaded: 1500 bytes
```

---

## 🎯 Gemini CLI 작업 제안

### **즉시 수행:**
1. Storage 파일 업로드 확인
2. App 전체 기능 테스트
3. Mock → DB 전환 (실제 Supabase 연동)

### **다음 단계:**
4. 추가 작품 등록 (최소 3-5개)
5. 유료 작품 + 구매 플로우 테스트
6. RevenueCat Test Store 제품 설정
7. Edge Function 구현 (purchase verification)

### **최적화:**
8. 에러 처리 강화
9. 로딩 UI 개선
10. 오프라인 모드 지원 (캐시 활용)

---

## 📞 연락 정보

**프로젝트 위치:** `/Users/sangbaekyu/Desktop/korean_literature`

**중요 링크:**
- Supabase Dashboard: https://app.supabase.com
- RevenueCat Dashboard: https://app.revenuecat.com

**기술 스택 문서:**
- Flutter: https://flutter.dev
- Riverpod: https://riverpod.dev
- Supabase: https://supabase.com/docs
- RevenueCat: https://docs.revenuecat.com

---

## 🎉 마무리

**현재 상태:** 
- ✅ Database 완료
- ✅ Storage 정책 완료
- ✅ Flutter 코드 완료
- ✅ Mock → Supabase 전환 완료
- ⏳ Storage 파일 업로드 필요
- ⏳ 전체 기능 테스트 필요

**다음 작업자를 위한 한 마디:**
Storage에 파일 2개만 업로드하면 바로 테스트 가능합니다! 
`supabase/sample_contents/arabic/lucky_day/` 폴더의 파일들을 
Supabase Storage에 업로드하고 앱을 실행하면 작품을 읽을 수 있습니다! 🚀

**Good luck and happy coding!** 🎯

---

**Handoff Date:** 2025-12-30 22:30 KST  
**Status:** Ready for Next Phase ✅

