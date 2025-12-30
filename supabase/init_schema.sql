-- ============================================================================
-- Korean Literature App - Complete Database Setup
-- 한 번에 실행 가능한 초기화 스크립트
-- ============================================================================
-- 
-- 사용법:
-- 1. Supabase Dashboard → SQL Editor → New Query
-- 2. 이 파일 전체를 복사해서 붙여넣기
-- 3. Run 버튼 클릭
-- 4. 완료!
--
-- ============================================================================

-- ============================================================================
-- 기존 데이터 초기화 (주의: 모든 데이터가 삭제됩니다!)
-- ============================================================================

DO $$ 
BEGIN
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
    
    RAISE NOTICE '✅ Cleanup completed: All existing tables, policies, and functions removed';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Cleanup warning: %', SQLERRM;
END $$;

-- ============================================================================
-- Extensions 활성화
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 공통 함수: updated_at 자동 업데이트
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 1. PROFILES 테이블 (사용자 프로필)
-- ============================================================================

CREATE TABLE public.profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    is_admin boolean NOT NULL DEFAULT false,
    username text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- RLS 활성화
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 모든 사용자가 프로필 조회 가능
CREATE POLICY "Public profiles are viewable" 
    ON public.profiles FOR SELECT 
    USING (true);

-- RLS 정책: 사용자는 자신의 프로필만 수정 (is_admin 제외)
CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (
        auth.uid() = user_id 
        AND is_admin = (SELECT is_admin FROM public.profiles WHERE user_id = auth.uid())
    );

-- 트리거: updated_at 자동 업데이트
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 트리거: 신규 사용자 자동 프로필 생성
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

-- ============================================================================
-- 2. COLLECTIONS 테이블 (작품 컬렉션)
-- ============================================================================

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

-- RLS 활성화
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 모든 사용자가 컬렉션 조회 가능
CREATE POLICY "Allow public read access to collections" 
    ON public.collections FOR SELECT 
    USING (true);

-- RLS 정책: Admin만 컬렉션 관리 가능
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

-- 트리거: updated_at 자동 업데이트
CREATE TRIGGER update_collections_updated_at
    BEFORE UPDATE ON public.collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- 3. STORIES 테이블 (Hybrid Storage 아키텍처)
-- ⚠️ DB: 제목, 서문, 해설 (미리보기)
-- ⚠️ Storage: 본문만 (구입 후 다운로드)
-- ============================================================================

CREATE TABLE public.stories (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id uuid REFERENCES public.collections(id) ON DELETE CASCADE NOT NULL,
    
    -- 메타데이터 (DB 저장 - 미리보기용)
    title_ar text NOT NULL,
    intro_ar text,                             -- 서문 (DB 저장)
    commentary_ar text,                        -- 해설/주석 (DB 저장)
    
    -- 본문 콘텐츠 (Storage 참조)
    content_url text,                          -- Storage 폴더 경로: 'arabic/lucky_day'
    content_version integer NOT NULL DEFAULT 1, -- 콘텐츠 버전 (캐시 무효화)
    content_size_bytes bigint,                 -- 콘텐츠 크기 (바이트)
    
    -- 기타
    order_index integer NOT NULL DEFAULT 0,
    is_free boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- RLS 활성화
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 모든 사용자가 Story 메타데이터 조회 가능
CREATE POLICY "Allow public read access to stories" 
    ON public.stories FOR SELECT 
    USING (true);

-- RLS 정책: Admin만 Story 관리 가능
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
CREATE INDEX idx_stories_order ON public.stories(order_index);
CREATE INDEX idx_stories_is_free ON public.stories(is_free);
CREATE INDEX idx_stories_content_url ON public.stories(content_url);

-- 트리거: updated_at 자동 업데이트
CREATE TRIGGER update_stories_updated_at
    BEFORE UPDATE ON public.stories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- 4. ENTITLEMENTS 테이블 (사용자 권한)
-- ============================================================================

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

-- RLS 활성화
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 권한만 조회 가능
CREATE POLICY "Allow users to view their own entitlements" 
    ON public.entitlements FOR SELECT 
    USING (auth.uid() = user_id);

-- RLS 정책: Service Role만 권한 관리 가능 (Edge Function용)
CREATE POLICY "Allow service role to manage entitlements" 
    ON public.entitlements FOR ALL 
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- 인덱스
CREATE INDEX idx_entitlements_user ON public.entitlements(user_id);
CREATE INDEX idx_entitlements_collection ON public.entitlements(collection_id);
CREATE INDEX idx_entitlements_expires_at ON public.entitlements(expires_at);

-- ============================================================================
-- 5. PURCHASES 테이블 (구매 기록)
-- ============================================================================

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

-- RLS 활성화
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 구매 내역만 조회 가능
CREATE POLICY "Allow users to view their own purchases" 
    ON public.purchases FOR SELECT 
    USING (auth.uid() = user_id);

-- RLS 정책: Service Role만 구매 기록 생성 가능 (Edge Function용)
CREATE POLICY "Allow service role to create purchases" 
    ON public.purchases FOR INSERT 
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- 인덱스
CREATE INDEX idx_purchases_user ON public.purchases(user_id);
CREATE INDEX idx_purchases_collection ON public.purchases(collection_id);
CREATE INDEX idx_purchases_transaction_id ON public.purchases(transaction_id);
CREATE INDEX idx_purchases_created_at ON public.purchases(created_at DESC);

-- ============================================================================
-- 6. EVENTS 테이블 (이벤트 로깅)
-- ============================================================================

CREATE TABLE public.events (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type text NOT NULL,
    event_data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- RLS 활성화
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 인증된 사용자만 이벤트 생성 가능
CREATE POLICY "Allow authenticated users to insert events" 
    ON public.events FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- 인덱스
CREATE INDEX idx_events_user ON public.events(user_id);
CREATE INDEX idx_events_type ON public.events(event_type);
CREATE INDEX idx_events_created_at ON public.events(created_at DESC);

-- ============================================================================
-- 샘플 데이터 삽입
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

-- Stories 샘플 데이터 (Storage 파일과 연결)
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
    'arabic/lucky_day',  -- ⚠️ Storage 폴더 경로 (content.txt, _meta.json 포함)
    1,
    1500,
    1,
    true);

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '✅ ============================================';
    RAISE NOTICE '✅ Database initialization completed!';
    RAISE NOTICE '✅ ============================================';
    RAISE NOTICE '';
    RAISE NOTICE '📦 Tables created:';
    RAISE NOTICE '   - profiles (사용자 프로필)';
    RAISE NOTICE '   - collections (작품 컬렉션)';
    RAISE NOTICE '   - stories (작품, Hybrid Storage)';
    RAISE NOTICE '   - entitlements (사용자 권한)';
    RAISE NOTICE '   - purchases (구매 기록)';
    RAISE NOTICE '   - events (이벤트 로그)';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 RLS policies enabled for all tables';
    RAISE NOTICE '📊 Sample data inserted:';
    RAISE NOTICE '   - 1 collection (무료 컬렉션)';
    RAISE NOTICE '   - 1 story (무료, Lucky Day)';
    RAISE NOTICE '   - Storage: arabic/lucky_day/';
    RAISE NOTICE '     ├── content.txt (본문)';
    RAISE NOTICE '     └── _meta.json (version: 1)';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '   1. Create Storage bucket "story-contents" (Private)';
    RAISE NOTICE '   2. Run storage_policies.sql for Storage RLS';
    RAISE NOTICE '   3. Upload JSON files to Storage';
    RAISE NOTICE '   4. Test the app!';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Ready to use!';
    RAISE NOTICE '';
END $$;

