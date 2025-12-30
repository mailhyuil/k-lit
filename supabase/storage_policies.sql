-- ============================================================================
-- Supabase Storage Bucket Policies
-- story-contents 버킷에 대한 접근 제어
-- ============================================================================

-- ============================================================================
-- 1. Bucket 생성 (Dashboard에서 수동으로 생성하거나 아래 명령 실행)
-- ============================================================================

-- Bucket: story-contents
-- Public: false (중요! Public이면 누구나 다운로드 가능)
-- File size limit: 10MB
-- Allowed MIME types: application/json

-- Dashboard에서 생성하거나, SQL로 생성:
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('story-contents', 'story-contents', false);

-- ============================================================================
-- 2. SELECT Policy (다운로드 권한)
-- ⚠️ 핵심: 무료 작품이거나 구매한 사용자만 다운로드 가능
-- ============================================================================

CREATE POLICY "Allow download if free or purchased"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'story-contents'
  AND (
    -- Case 1: 무료 작품인 경우 (누구나 다운로드 가능)
    -- 경로 패턴: 'arabic/lucky_day/content.txt' 또는 'arabic/lucky_day/_meta.json'
    EXISTS (
      SELECT 1 FROM public.stories
      WHERE (
        storage.objects.name LIKE stories.content_url || '/content.txt'
        OR storage.objects.name LIKE stories.content_url || '/_meta.json'
      )
      AND stories.is_free = true
    )
    OR
    -- Case 2: 유료 작품이지만 사용자가 해당 컬렉션을 구매한 경우
    EXISTS (
      SELECT 1 FROM public.stories
      JOIN public.entitlements 
        ON entitlements.collection_id = stories.collection_id
      WHERE (
        storage.objects.name LIKE stories.content_url || '/content.txt'
        OR storage.objects.name LIKE stories.content_url || '/_meta.json'
      )
      AND entitlements.user_id = auth.uid()
      AND (entitlements.expires_at IS NULL OR entitlements.expires_at > now())
    )
  )
);

-- ============================================================================
-- 3. INSERT Policy (업로드 권한)
-- ⚠️ Admin만 파일 업로드 가능
-- ============================================================================

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

-- ============================================================================
-- 4. UPDATE Policy (파일 수정 권한)
-- ⚠️ Admin만 파일 수정 가능
-- ============================================================================

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

-- ============================================================================
-- 5. DELETE Policy (파일 삭제 권한)
-- ⚠️ Admin만 파일 삭제 가능
-- ============================================================================

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

-- ============================================================================
-- 6. RLS 활성화 (필수!)
-- ============================================================================

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. 정책 확인 쿼리
-- ============================================================================

-- Storage Objects 정책 목록 확인
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
AND schemaname = 'storage';

-- ============================================================================
-- 8. 테스트 쿼리
-- ============================================================================

-- 현재 사용자가 특정 파일을 다운로드할 수 있는지 테스트
-- (실제 auth.uid()로 테스트)
SELECT 
  so.name,
  s.title_ar,
  s.is_free,
  CASE 
    WHEN s.is_free THEN '무료 (다운로드 가능)'
    WHEN EXISTS (
      SELECT 1 FROM public.entitlements e
      WHERE e.collection_id = s.collection_id
      AND e.user_id = auth.uid()
      AND (e.expires_at IS NULL OR e.expires_at > now())
    ) THEN '구매 완료 (다운로드 가능)'
    ELSE '구매 필요 (다운로드 불가)'
  END as download_status
FROM storage.objects so
JOIN public.stories s ON s.content_url = so.name
WHERE so.bucket_id = 'story-contents'
LIMIT 10;

-- ============================================================================
-- 9. 정책 삭제 (재설정이 필요한 경우)
-- ============================================================================

-- 기존 정책 삭제
-- DROP POLICY IF EXISTS "Allow download if free or purchased" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow admin to upload" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow admin to update" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow admin to delete" ON storage.objects;

-- ============================================================================
-- 완료!
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Storage policies created successfully!';
  RAISE NOTICE '📦 Bucket: story-contents';
  RAISE NOTICE '🔒 Access control:';
  RAISE NOTICE '   - Free stories: Anyone (authenticated) can download';
  RAISE NOTICE '   - Paid stories: Only users with entitlements can download';
  RAISE NOTICE '   - Upload/Update/Delete: Admin only';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Next steps:';
  RAISE NOTICE '   1. Create "story-contents" bucket in Supabase Dashboard';
  RAISE NOTICE '   2. Set bucket to PRIVATE (not public)';
  RAISE NOTICE '   3. Run this SQL file in SQL Editor';
  RAISE NOTICE '   4. Upload JSON files to the bucket';
  RAISE NOTICE '   5. Test download with authenticated user';
END $$;

