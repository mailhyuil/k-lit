-- ============================================================================
-- Korean Literature App - Complete Database & Storage Setup
-- 한 번에 실행 가능한 통합 스키마
-- ============================================================================
-- 
-- 이 파일은 다음을 포함합니다:
-- 1. Database Tables (6개)
-- 2. RLS Policies (모든 테이블)
-- 3. Storage Policies (story-contents 버킷)
-- 4. Sample Data (1 collection, 1 story)
--
-- 사용법:
-- 1. Supabase Dashboard → SQL Editor → New Query
-- 2. 이 파일 전체를 복사해서 붙여넣기
-- 3. Run 버튼 클릭
-- 4. 완료!
--
-- ⚠️ 주의: 기존 데이터가 모두 삭제됩니다!
--
-- ============================================================================

-- ============================================================================
-- PART 1: 기존 데이터 초기화
-- ============================================================================

DO $$ 
BEGIN
    RAISE NOTICE '🗑️ Cleaning up existing data...';
    
    -- Storage 정책 삭제
    DROP POLICY IF EXISTS "Allow download if free or purchased" ON storage.objects;
    DROP POLICY IF EXISTS "Allow admin to upload" ON storage.objects;
    DROP POLICY IF EXISTS "Allow admin to update" ON storage.objects;
    DROP POLICY IF EXISTS "Allow admin to delete" ON storage.objects;
    
    -- 기존 테이블 삭제 (CASCADE로 정책, 트리거, 제약조건 모두 삭제)
    DROP TABLE IF EXISTS public.events CASCADE;
    DROP TABLE IF EXISTS public.purchases CASCADE;
    DROP TABLE IF EXISTS public.entitlements CASCADE;
    DROP TABLE IF EXISTS public.stories CASCADE;
    DROP TABLE IF EXISTS public.collections CASCADE;
    DROP TABLE IF EXISTS public.profiles CASCADE;
    
    -- 기존 함수 삭제
    DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
    DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
    
    RAISE NOTICE '✅ Cleanup completed!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Cleanup warning: %', SQLERRM;
END $$;

-- ============================================================================
-- PART 2: Extensions 활성화
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PART 3: 공통 함수
-- ============================================================================

-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 신규 사용자 자동 프로필 생성 함수
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PART 4: 테이블 생성
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4.1 PROFILES 테이블
-- ----------------------------------------------------------------------------

CREATE TABLE public.profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    is_admin boolean NOT NULL DEFAULT false,
    username text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

COMMENT ON TABLE public.profiles IS '사용자 프로필 및 권한 관리';
COMMENT ON COLUMN public.profiles.is_admin IS 'Admin 권한 여부 (콘텐츠 관리)';

-- ----------------------------------------------------------------------------
-- 4.2 COLLECTIONS 테이블
-- ----------------------------------------------------------------------------

CREATE TABLE public.collections (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_ar text NOT NULL,
    description_ar text,
    cover_url text,
    price_tier text NOT NULL DEFAULT 'free',
    is_free boolean NOT NULL DEFAULT false,
    order_index integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

COMMENT ON TABLE public.collections IS '작품 컬렉션 (주제별 묶음)';
COMMENT ON COLUMN public.collections.title_ar IS '아랍어 제목';
COMMENT ON COLUMN public.collections.price_tier IS '가격 등급: free, basic, premium';

-- ----------------------------------------------------------------------------
-- 4.3 STORIES 테이블 (Hybrid Storage)
-- ----------------------------------------------------------------------------

CREATE TABLE public.stories (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,
    
    -- DB 저장 (미리보기용)
    title_ar text NOT NULL,
    intro_ar text,
    commentary_ar text,
    
    -- Storage 참조 (구입 후 다운로드)
    content_url text,
    content_version integer NOT NULL DEFAULT 1,
    content_size_bytes bigint,
    
    order_index integer NOT NULL DEFAULT 0,
    is_free boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

COMMENT ON TABLE public.stories IS '개별 작품 (Hybrid Storage)';
COMMENT ON COLUMN public.stories.intro_ar IS '서문 (DB 저장, 미리보기)';
COMMENT ON COLUMN public.stories.commentary_ar IS '해설 (DB 저장, 미리보기)';
COMMENT ON COLUMN public.stories.content_url IS 'Storage 폴더 경로: arabic/lucky_day';

-- ----------------------------------------------------------------------------
-- 4.4 ENTITLEMENTS 테이블
-- ----------------------------------------------------------------------------

CREATE TABLE public.entitlements (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,
    source text NOT NULL DEFAULT 'revenuecat',
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    
    UNIQUE(user_id, collection_id)
);

COMMENT ON TABLE public.entitlements IS '사용자 권한 (구매한 컬렉션)';
COMMENT ON COLUMN public.entitlements.source IS '권한 출처: revenuecat, promo, admin';

-- ----------------------------------------------------------------------------
-- 4.5 PURCHASES 테이블
-- ----------------------------------------------------------------------------

CREATE TABLE public.purchases (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,
    product_id text NOT NULL,
    transaction_id text UNIQUE NOT NULL,
    source text NOT NULL DEFAULT 'revenuecat',
    amount_cents integer,
    currency text,
    status text NOT NULL DEFAULT 'completed',
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

COMMENT ON TABLE public.purchases IS '구매 기록 (결제 히스토리)';
COMMENT ON COLUMN public.purchases.transaction_id IS 'RevenueCat 트랜잭션 ID (unique)';

-- ----------------------------------------------------------------------------
-- 4.6 EVENTS 테이블
-- ----------------------------------------------------------------------------

CREATE TABLE public.events (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type text NOT NULL,
    event_data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

COMMENT ON TABLE public.events IS '이벤트 로깅 (분석용)';
COMMENT ON COLUMN public.events.event_type IS '이벤트 타입: story_read, purchase_attempt 등';

-- ============================================================================
-- PART 5: RLS (Row Level Security) 활성화 및 정책
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 5.1 PROFILES RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable" 
    ON public.profiles FOR SELECT 
    USING (true);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (
        auth.uid() = user_id 
        AND is_admin = (SELECT is_admin FROM public.profiles WHERE user_id = auth.uid())
    );

-- ----------------------------------------------------------------------------
-- 5.2 COLLECTIONS RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to collections" 
    ON public.collections FOR SELECT 
    USING (true);

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

-- ----------------------------------------------------------------------------
-- 5.3 STORIES RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to stories" 
    ON public.stories FOR SELECT 
    USING (true);

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

-- ----------------------------------------------------------------------------
-- 5.4 ENTITLEMENTS RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to view their own entitlements" 
    ON public.entitlements FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Allow service role to manage entitlements" 
    ON public.entitlements FOR ALL 
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ----------------------------------------------------------------------------
-- 5.5 PURCHASES RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to view their own purchases" 
    ON public.purchases FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Allow service role to create purchases" 
    ON public.purchases FOR INSERT 
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ----------------------------------------------------------------------------
-- 5.6 EVENTS RLS
-- ----------------------------------------------------------------------------

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to insert events" 
    ON public.events FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- PART 6: 인덱스 생성
-- ============================================================================

-- COLLECTIONS
CREATE INDEX idx_collections_order ON public.collections(order_index);
CREATE INDEX idx_collections_is_free ON public.collections(is_free);

-- STORIES
CREATE INDEX idx_stories_collection ON public.stories(collection_id);
CREATE INDEX idx_stories_order ON public.stories(order_index);
CREATE INDEX idx_stories_is_free ON public.stories(is_free);
CREATE INDEX idx_stories_content_url ON public.stories(content_url);

-- ENTITLEMENTS
CREATE INDEX idx_entitlements_user ON public.entitlements(user_id);
CREATE INDEX idx_entitlements_collection ON public.entitlements(collection_id);
CREATE INDEX idx_entitlements_expires_at ON public.entitlements(expires_at);

-- PURCHASES
CREATE INDEX idx_purchases_user ON public.purchases(user_id);
CREATE INDEX idx_purchases_collection ON public.purchases(collection_id);
CREATE INDEX idx_purchases_transaction_id ON public.purchases(transaction_id);
CREATE INDEX idx_purchases_created_at ON public.purchases(created_at DESC);

-- EVENTS
CREATE INDEX idx_events_user ON public.events(user_id);
CREATE INDEX idx_events_type ON public.events(event_type);
CREATE INDEX idx_events_created_at ON public.events(created_at DESC);

-- ============================================================================
-- PART 7: 트리거 설정
-- ============================================================================

-- PROFILES
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- COLLECTIONS
CREATE TRIGGER update_collections_updated_at
    BEFORE UPDATE ON public.collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- STORIES
CREATE TRIGGER update_stories_updated_at
    BEFORE UPDATE ON public.stories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- PART 8: Storage RLS 정책
-- ⚠️ 주의: Storage 정책은 별도로 적용해야 합니다!
-- ⚠️ Dashboard → Storage → Policies 에서 수동으로 생성하거나
-- ⚠️ storage_policies.sql 파일을 별도로 실행하세요.
-- ============================================================================

-- Storage 정책은 일반 SQL Editor에서 권한 오류가 발생할 수 있습니다.
-- 대신 아래 방법 중 하나를 사용하세요:
--
-- 방법 1: Supabase Dashboard UI 사용
--   1. Storage → story-contents bucket → Policies
--   2. 아래 정책들을 수동으로 생성
--
-- 방법 2: storage_policies.sql 파일 실행
--   1. supabase/storage_policies.sql 파일 열기
--   2. SQL Editor에서 별도로 실행
--
-- 필요한 정책:
--   1. "Allow download if free or purchased" (SELECT)
--   2. "Allow admin to upload" (INSERT)
--   3. "Allow admin to update" (UPDATE)
--   4. "Allow admin to delete" (DELETE)
--
-- 자세한 내용은 storage_policies.sql 파일 참조

-- ============================================================================
-- PART 9: 샘플 데이터 삽입
-- ============================================================================

-- Collections 샘플 데이터
INSERT INTO public.collections (id, title_ar, description_ar, price_tier, is_free, order_index)
VALUES 
   ('11111111-1111-1111-1111-111111111111',
    'قصص كورية كلاسيكية',
    'مجموعة من القصص الكورية الكلاسيكية المترجمة إلى العربية',
    'basic',
    true,
    1);

-- Stories 샘플 데이터
INSERT INTO public.stories (
    id,
    collection_id,
    title_ar,
    intro_ar,
    commentary_ar,
    content_url,
    content_version,
    content_size_bytes,
    order_index,
    is_free
)
VALUES 
   ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'يوم محظوظ',
    'قصة قصيرة لكاتب كوري مشهور عن يوم في حياة سائق عربة في سيول خلال فترة الاحتلال الياباني.',
    'تعتبر "يوم محظوظ" من أهم الأعمال في الأدب الكوري الحديث. كتبها هيون جين-geon في عام 1924، وتصور بشكل حي الواقع القاسي للطبقة العاملة في كوريا تحت الاحتلال الياباني.',
    'arabic/lucky_day',
    1,
    1500,
    1,
    true);

-- ============================================================================
-- PART 10: 완료 메시지
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '✅ Database Setup Completed!';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📦 Database Tables Created (6):';
    RAISE NOTICE '   1. profiles        - 사용자 프로필';
    RAISE NOTICE '   2. collections     - 작품 컬렉션';
    RAISE NOTICE '   3. stories         - 개별 작품 (Hybrid Storage)';
    RAISE NOTICE '   4. entitlements    - 사용자 권한';
    RAISE NOTICE '   5. purchases       - 구매 기록';
    RAISE NOTICE '   6. events          - 이벤트 로그';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 RLS Policies Applied:';
    RAISE NOTICE '   ✅ All database tables: Row-level security enabled';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Sample Data Inserted:';
    RAISE NOTICE '   - 1 collection: قصص كورية كلاسيكية';
    RAISE NOTICE '   - 1 story: يوم محظوظ (Lucky Day)';
    RAISE NOTICE '   - Storage path: arabic/lucky_day/';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next Steps (IMPORTANT!):';
    RAISE NOTICE '   1. ✅ Database: Ready';
    RAISE NOTICE '   2. ⚠️  Storage Policies: Run storage_policies.sql separately';
    RAISE NOTICE '      (Storage 정책은 권한 문제로 별도 실행 필요)';
    RAISE NOTICE '   3. ⏳ Storage Bucket: Create "story-contents" (Private)';
    RAISE NOTICE '   4. ⏳ Upload Files to Storage:';
    RAISE NOTICE '      - arabic/lucky_day/content.txt';
    RAISE NOTICE '      - arabic/lucky_day/_meta.json';
    RAISE NOTICE '   5. ⏳ Test: flutter run';
    RAISE NOTICE '';
    RAISE NOTICE '💡 To apply Storage policies:';
    RAISE NOTICE '   → Open supabase/storage_policies.sql';
    RAISE NOTICE '   → Run it in SQL Editor';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Database ready! Next: Storage setup!';
    RAISE NOTICE '';
END $$;

