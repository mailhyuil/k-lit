# Supabase Database Schema

Korean Essential Literature (Arabic) 앱의 데이터베이스 스키마입니다.

## 아키텍처 개요

이 앱은 **컬렉션 중심 구조 + Storage 기반 콘텐츠 관리**를 사용합니다:

- **Collections**: 테마별로 묶인 작품 모음 (예: "현대 한국 단편", "전통 민담")
- **Stories**: 각 컬렉션에 속한 개별 작품의 **메타데이터**
- **Supabase Storage**: 작품의 실제 콘텐츠 (JSON 파일)
- **Entitlements**: 사용자가 구매한 컬렉션에 대한 접근 권한
- **Purchases**: 실제 결제 거래 기록

### ⚠️ 중요: Hybrid Storage 아키텍처

**DB와 Storage를 전략적으로 분리:**

- **DB 저장**: 제목, 서문(intro_ar), 해설(commentary_ar), Storage URL, 버전
- **Storage 저장**: 본문(body_ar)만

**이렇게 하는 이유:**

1. **미리보기 제공**: 서문과 해설은 구매 전에 미리 볼 수 있어야 함
2. **권한 제어**: 본문만 구입 후 다운로드 가능
3. **DB 효율**: 본문은 긴 텍스트라 Storage에 저장

**장점:**

- ✅ 구매 전 미리보기 가능 (서문, 해설)
- ✅ 본문은 구입 후에만 다운로드 (권한 제어)
- ✅ 빠른 목록 조회 (본문 제외)
- ✅ 오프라인 읽기 지원 (로컬 캐시)
- ✅ CDN을 통한 빠른 다운로드

**Storage 구조:**

```
supabase-storage/story-contents/    (Public 버킷, RLS 적용)
├── story-001.json    (본문만)
├── story-002.json    (본문만)
└── ...
```

**JSON 파일 형식:**

```json
{
  "version": 1,
  "body_ar": "본문..."
}
```

---

## 1. `collections` 테이블

테마별 작품 컬렉션을 저장합니다.

```sql
CREATE TABLE public.collections (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_ar text NOT NULL,                    -- 아랍어 제목
    description_ar text,                       -- 아랍어 설명
    cover_path text,                           -- Supabase Storage 경로
    price_tier text NOT NULL DEFAULT 'free',   -- 'free', 'tier1', 'tier2', etc.
    is_free boolean NOT NULL DEFAULT false,    -- 무료 여부
    order_index integer NOT NULL DEFAULT 0,    -- 정렬 순서
    rc_identifier text,                       -- RevenueCat 식별자
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 컬렉션 목록을 볼 수 있음
CREATE POLICY "Allow public read access to collections"
    ON public.collections FOR SELECT USING (true);

-- Admin만 컬렉션 생성/수정/삭제 가능
CREATE POLICY "Allow admin to manage collections"
    ON public.collections FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true
    ));

-- 인덱스
CREATE INDEX idx_collections_order ON public.collections(order_index);
CREATE INDEX idx_collections_is_free ON public.collections(is_free);
```

---

## 2. `stories` 테이블 (Hybrid Storage)

각 컬렉션에 속한 작품의 **메타데이터와 미리보기**를 저장합니다.

⚠️ **Hybrid 저장 방식:**

- **DB**: 제목, 서문(intro_ar), 해설(commentary_ar) - 구매 전 미리보기용
- **Storage**: 본문(body_ar) - 구매 후 다운로드

```sql
CREATE TABLE public.stories (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,

    -- 메타데이터 (DB에 저장 - 미리보기용)
    title_ar text NOT NULL,                    -- 아랍어 제목
    intro_ar text,                             -- 아랍어 서문 (미리보기)
    commentary_ar text,                        -- 아랍어 해설 (미리보기)

    -- Storage 참조 (본문만 Storage에 저장)
    content_url text NOT NULL,                 -- Storage 경로: 'story-contents/{id}.json'
    content_version integer NOT NULL DEFAULT 1,-- 콘텐츠 버전 (캐시 무효화용)
    content_size_bytes integer,                -- 파일 크기 (다운로드 예상 시간 표시용)

    -- 정렬 및 접근 제어
    order_index integer NOT NULL DEFAULT 0,    -- 컬렉션 내 정렬 순서
    is_free boolean NOT NULL DEFAULT false,    -- 무료 체험용 작품 여부
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- 무료 작품이거나, 사용자가 해당 컬렉션에 대한 권한이 있으면 읽기 허용
CREATE POLICY "Allow read access to stories"
    ON public.stories FOR SELECT
    USING (
        is_free = true
        OR EXISTS (
            SELECT 1 FROM public.entitlements
            WHERE entitlements.user_id = auth.uid()
            AND entitlements.collection_id = stories.collection_id
            AND (entitlements.expires_at IS NULL OR entitlements.expires_at > now())
        )
    );

-- Admin만 작품 생성/수정/삭제 가능
CREATE POLICY "Allow admin to manage stories"
    ON public.stories FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true
    ));

-- 인덱스
CREATE INDEX idx_stories_collection ON public.stories(collection_id);
CREATE INDEX idx_stories_order ON public.stories(collection_id, order_index);
CREATE INDEX idx_stories_is_free ON public.stories(is_free);
```

---

## 3. `entitlements` 테이블

사용자가 구매한 컬렉션에 대한 접근 권한을 관리합니다.

```sql
CREATE TABLE public.entitlements (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,
    source text NOT NULL DEFAULT 'purchase',   -- 'purchase', 'promo', 'subscription'
    product_id text,                           -- RevenueCat 또는 스토어 상품 ID
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,       -- NULL이면 영구 소유
    UNIQUE (user_id, collection_id)           -- 사용자당 컬렉션당 하나의 권한
);

ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 권한만 볼 수 있음
CREATE POLICY "Users can read their own entitlements"
    ON public.entitlements FOR SELECT
    USING (auth.uid() = user_id);

-- 권한 생성은 Edge Function에서만 (서버 사이드)
-- 클라이언트에서는 INSERT 불가
CREATE POLICY "Only Edge Functions can insert entitlements"
    ON public.entitlements FOR INSERT
    WITH CHECK (false);  -- Edge Function은 service_role key 사용

-- 인덱스
CREATE INDEX idx_entitlements_user ON public.entitlements(user_id);
CREATE INDEX idx_entitlements_collection ON public.entitlements(collection_id);
CREATE INDEX idx_entitlements_expires ON public.entitlements(expires_at) WHERE expires_at IS NOT NULL;
```

---

## 4. `purchases` 테이블

실제 결제 거래 기록을 저장합니다.

```sql
CREATE TABLE public.purchases (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    platform text NOT NULL,                    -- 'ios', 'android', 'web'
    product_id text NOT NULL,                  -- 스토어 상품 ID
    rc_transaction_id text,                    -- RevenueCat 트랜잭션 ID
    raw_payload_json jsonb,                    -- 원본 영수증 데이터
    status text NOT NULL DEFAULT 'pending',    -- 'pending', 'verified', 'failed'
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    verified_at timestamp with time zone
);

ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 구매 기록만 볼 수 있음
CREATE POLICY "Users can read their own purchases"
    ON public.purchases FOR SELECT
    USING (auth.uid() = user_id);

-- 구매 기록 생성은 Edge Function에서만
CREATE POLICY "Only Edge Functions can insert purchases"
    ON public.purchases FOR INSERT
    WITH CHECK (false);  -- Edge Function은 service_role key 사용

-- 인덱스
CREATE INDEX idx_purchases_user ON public.purchases(user_id);
CREATE INDEX idx_purchases_status ON public.purchases(status);
CREATE INDEX idx_purchases_rc_transaction ON public.purchases(rc_transaction_id);
```

---

## 5. `profiles` 테이블

사용자 프로필 및 권한 정보를 저장합니다.

```sql
CREATE TABLE public.profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    is_admin boolean NOT NULL DEFAULT false,   -- 관리자 여부
    username text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 프로필을 볼 수 있음 (is_admin은 제외)
CREATE POLICY "Public profiles are viewable"
    ON public.profiles FOR SELECT
    USING (true);

-- 사용자는 자신의 프로필만 수정 가능 (is_admin 제외)
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND is_admin = (SELECT is_admin FROM public.profiles WHERE user_id = auth.uid()));

-- 프로필 자동 생성 트리거
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## 6. `events` 테이블

사용자 행동 로깅을 위한 이벤트 테이블입니다.

```sql
CREATE TABLE public.events (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,  -- NULL 허용 (게스트)
    event_name text NOT NULL,                  -- 'view_collection', 'view_story', 'paywall_view', etc.
    props_json jsonb,                          -- 이벤트 관련 추가 데이터
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 이벤트만 볼 수 있음
CREATE POLICY "Users can read their own events"
    ON public.events FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

-- 이벤트 생성은 모두 허용 (분석용)
CREATE POLICY "Anyone can insert events"
    ON public.events FOR INSERT
    WITH CHECK (true);

-- 인덱스 (분석용)
CREATE INDEX idx_events_user ON public.events(user_id);
CREATE INDEX idx_events_name ON public.events(event_name);
CREATE INDEX idx_events_created ON public.events(created_at DESC);
```

---

## 7. `reading_progress` 테이블

사용자의 작품 읽기 진도를 저장합니다.

```sql
CREATE TABLE public.reading_progress (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    story_id uuid REFERENCES public.stories(id) ON DELETE CASCADE NOT NULL,
    last_position integer NOT NULL DEFAULT 0,  -- 마지막 읽은 위치 (글자 수 또는 페이지)
    completed boolean NOT NULL DEFAULT false,  -- 완독 여부
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    UNIQUE (user_id, story_id)                -- 사용자별 작품당 하나의 진도
);

ALTER TABLE public.reading_progress ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 진도만 읽기/생성/수정 가능
CREATE POLICY "Users can manage their own progress"
    ON public.reading_progress FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 인덱스
CREATE INDEX idx_reading_progress_user ON public.reading_progress(user_id);
CREATE INDEX idx_reading_progress_story ON public.reading_progress(story_id);
```

---

## 8. Seed Data (MVP)

MVP를 위한 초기 더미 데이터입니다.

```sql
-- 무료 컬렉션 1개
INSERT INTO public.collections (id, title_ar, description_ar, price_tier, is_free, order_index)
VALUES
    ('11111111-1111-1111-1111-111111111111',
     'قصص قصيرة كورية مجانية',
     'مجموعة من القصص القصيرة الكورية الحديثة - مجاني للجميع',
     'free',
     true,
     1);

-- 유료 컬렉션 1개
INSERT INTO public.collections (id, title_ar, description_ar, price_tier, is_free, order_index)
VALUES
    ('22222222-2222-2222-2222-222222222222',
     'الأدب الكوري الكلاسيكي',
     'مجموعة من الأعمال الأدبية الكورية الكلاسيكية المترجمة',
     'tier1',
     false,
     2);

-- 무료 컬렉션의 작품 3개 (모두 무료)
INSERT INTO public.stories (collection_id, title_ar, intro_ar, body_ar, commentary_ar, order_index, is_free)
VALUES
    ('11111111-1111-1111-1111-111111111111',
     'يوم محظوظ',
     'قصة قصيرة لكاتب كوري مشهور عن يوم في حياة سائق عربة',
     'في صباح بارد من شتاء سيول، استيقظ كيم تشون هو مبكرًا كالعادة...',
     'تعتبر هذه القصة من أهم الأعمال في الأدب الكوري الحديث، حيث تصور حياة الطبقة العاملة في كوريا في فترة الاستعمار الياباني.',
     1,
     true),
    ('11111111-1111-1111-1111-111111111111',
     'الربيع والربيع',
     'قصة عن الأمل والتجديد في فصل الربيع',
     'عندما تتفتح أزهار الكرز في جبل نامسان...',
     'يستخدم الكاتب الربيع كرمز للأمل والتغيير الاجتماعي.',
     2,
     true),
    ('11111111-1111-1111-1111-111111111111',
     'صياد البحر',
     'حكاية صياد عجوز وعلاقته بالبحر',
     'على شواطئ بوسان، عاش صياد عجوز وحيد...',
     'تعكس القصة الفلسفة الكورية في التعايش مع الطبيعة.',
     3,
     true);

-- 유료 컬렉션의 작품 3개 (1개는 무료 체험용)
INSERT INTO public.stories (collection_id, title_ar, intro_ar, body_ar, commentary_ar, order_index, is_free)
VALUES
    ('22222222-2222-2222-2222-222222222222',
     'حكاية التنين الأزرق',
     'أسطورة كورية قديمة عن تنين يحمي القرية - مجانية للتجربة',
     'في زمن قديم، عاش تنين أزرق في أعماق نهر هان...',
     'هذه الأسطورة تعكس المعتقدات الكورية القديمة حول التنانين كحماة للشعب.',
     1,
     true),  -- 무료 체험용
    ('22222222-2222-2222-2222-222222222222',
     'الأميرة والقمر',
     'حكاية كلاسيكية عن أميرة ولعنة القمر',
     'في قصر جيونجبوك، ولدت أميرة في ليلة اكتمال القمر...',
     'تحليل أدبي لموضوعات الحب والتضحية في الأدب الكوري الكلاسيكي.',
     2,
     false),  -- 유료
    ('22222222-2222-2222-2222-222222222222',
     'الحكيم والجبل',
     'قصة فلسفية عن حكيم يعيش في الجبال',
     'في جبال سوراك، عاش حكيم عجوز بعيدًا عن العالم...',
     'تفسير فلسفي للمفاهيم البوذية والكونفوشيوسية في الثقافة الكورية.',
     3,
     false);  -- 유료
```

---

## 9. 유용한 쿼리

### 컬렉션의 모든 작품 조회

```sql
SELECT * FROM public.stories
WHERE collection_id = '11111111-1111-1111-1111-111111111111'
ORDER BY order_index;
```

### 사용자의 권한 조회

```sql
SELECT c.* FROM public.collections c
INNER JOIN public.entitlements e ON e.collection_id = c.id
WHERE e.user_id = auth.uid()
AND (e.expires_at IS NULL OR e.expires_at > now());
```

### 무료 체험 가능한 작품 조회

```sql
SELECT s.*, c.title_ar as collection_title
FROM public.stories s
INNER JOIN public.collections c ON c.id = s.collection_id
WHERE s.is_free = true
ORDER BY c.order_index, s.order_index;
```

---

## 10. Supabase Storage 정책

### Bucket 설정

- **Bucket 이름**: `story-contents`
- **Public**: `false` (Private, RLS로 접근 제어)
- **File size limit**: 10MB
- **Allowed MIME types**: `application/json`

### Storage RLS 정책

#### 1. SELECT (다운로드) 정책

```sql
CREATE POLICY "Allow download if free or purchased"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'story-contents'
  AND (
    -- 무료 작품: 누구나 다운로드 가능
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE stories.content_url = storage.objects.name
      AND stories.is_free = true
    )
    OR
    -- 유료 작품: 구매한 사용자만 다운로드 가능
    EXISTS (
      SELECT 1 FROM public.stories
      JOIN public.entitlements
        ON entitlements.collection_id = stories.collection_id
      WHERE stories.content_url = storage.objects.name
      AND entitlements.user_id = auth.uid()
      AND (entitlements.expires_at IS NULL OR entitlements.expires_at > now())
    )
  )
);
```

#### 2. INSERT (업로드) 정책

```sql
CREATE POLICY "Allow admin to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'story-contents'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND profiles.is_admin = true
  )
);
```

#### 3. UPDATE (수정) 정책

```sql
CREATE POLICY "Allow admin to update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'story-contents'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND profiles.is_admin = true
  )
);
```

#### 4. DELETE (삭제) 정책

```sql
CREATE POLICY "Allow admin to delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'story-contents'
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.user_id = auth.uid()
    AND profiles.is_admin = true
  )
);
```

### Storage 정책 적용

```sql
-- RLS 활성화
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 정책 확인
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage';
```

### 접근 제어 로직

```
사용자가 Story 본문 다운로드 시도
↓
Storage SELECT 정책 실행:
├─ stories.is_free = true?
│  └─ YES → ✅ 다운로드 허용
│  └─ NO → 다음 단계
├─ entitlements 테이블에서 확인:
│  ├─ user_id = auth.uid()?
│  ├─ collection_id 일치?
│  └─ expires_at > now() or NULL?
│     └─ YES → ✅ 다운로드 허용
│     └─ NO → ❌ 접근 거부
↓
결과:
✅ 다운로드 성공 → body_ar 반환
❌ 접근 거부 → 403 Forbidden
```

### 파일 구조

```
story-contents/
├── aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa.json
├── bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb.json
└── cccccccc-cccc-cccc-cccc-cccccccccccc.json
```

**파일 형식**:

```json
{
  "version": 1,
  "body_ar": "본문 내용..."
}
```

### 관련 파일

- `supabase/storage_policies.sql`: Storage RLS 정책 전체 코드
- `supabase/sample_contents/README.md`: 파일 업로드 가이드
- `lib/features/stories/services/story_storage_service.dart`: Storage 다운로드/업로드 서비스

---
