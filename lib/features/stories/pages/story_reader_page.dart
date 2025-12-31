import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/supabase_client.dart';
import 'package:flutter_application_1/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/font_size_provider.dart';
import '../../entitlements/providers/entitlement_provider.dart';
import '../providers/reader_controller.dart';
import '../providers/story_content_provider.dart';
import '../providers/story_provider.dart';

/// 작품 읽기 페이지 (페이지 단위 읽기)
class StoryReaderPage extends ConsumerStatefulWidget {
  final String storyId;

  const StoryReaderPage({super.key, required this.storyId});

  @override
  ConsumerState<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends ConsumerState<StoryReaderPage> {
  late PageController _pageController;
  bool _showControls = false; // 기본값 false로 변경
  double _fontSize = 20.0; // 기본 폰트 크기 증가
  List<String> _pages = [];
  int _currentPage = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _fontSize = ref.read(fontSizeProvider);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyProvider(widget.storyId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // 따뜻한 독서 배경색
      body: storyAsync.when(
        data: (story) {
          if (story == null) {
            return _buildNotFound(context);
          }
          final hasEntitlementFuture = ref.watch(hasEntitlementByStoryIdProvider(widget.storyId));

          final hasEntitlement = hasEntitlementFuture.value ?? false;

          if (story.isLocked && !story.isFree && !hasEntitlement) {
            return _buildLockedState(context);
          }

          // Body content 로드 (Storage에서)
          final contentAsync = ref.watch(storyContentProvider(widget.storyId));

          return contentAsync.when(
            data: (storyContent) {
              return _buildPagedReader(context, story, storyContent.bodyAr);
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF8B4513)),
                  SizedBox(height: 16),
                  Text(
                    'المحتوى يتم تحميله...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFF8B4513)),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل المحتوى',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  void _increaseFontSize() {
    if (_fontSize < 36.0) {
      final newFontSize = _fontSize + 1.0;
      ref.read(fontSizeProvider.notifier).setFontSize(newFontSize);
      setState(() {
        _fontSize = newFontSize;
        _pages = []; // 폰트 크기 변경 시 페이지 재계산
      });
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 14.0) {
      final newFontSize = _fontSize - 1.0;
      ref.read(fontSizeProvider.notifier).setFontSize(newFontSize);
      setState(() {
        _fontSize = newFontSize;
        _pages = []; // 폰트 크기 변경 시 페이지 재계산
      });
    }
  }

  Widget _buildPagedReader(BuildContext context, dynamic story, String bodyAr) {
    // 페이지 분할
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pages.isEmpty && mounted) {
        _splitPages(context, story, bodyAr);
      }
    });

    if (_pages.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)));
    }

    final isLastPage = _currentPage == _pages.length - 1;

    return Stack(
      children: [
        // 페이지 콘텐츠
        PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildPageContent(index);
          },
        ),

        // 왼쪽/오른쪽 클릭 영역 (아랍어 RTL UX)
        Row(
          children: [
            // 왼쪽 영역 (이전 페이지) - 아랍어 책은 왼쪽이 뒤로
            Expanded(
              child: GestureDetector(
                onTap: _previousPage,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // 중앙 영역 (컨트롤 토글)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // 오른쪽 영역 (다음 페이지) - 아랍어 책은 오른쪽에서 왼쪽으로
            Expanded(
              child: GestureDetector(
                onTap: _nextPage,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),

        // AppBar (오버레이)
        if (_showControls)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.black54, Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      // 뒤로 가기
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // 제목
                      const Expanded(
                        child: Text(
                          '작품 읽기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // 글씨 크기 감소
                      IconButton(
                        icon: const Icon(Icons.text_decrease, color: Colors.white),
                        onPressed: _decreaseFontSize,
                        tooltip: '글씨 축소',
                      ),
                      // 현재 글씨 크기 표시
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_fontSize.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 글씨 크기 증가
                      IconButton(
                        icon: const Icon(Icons.text_increase, color: Colors.white),
                        onPressed: _increaseFontSize,
                        tooltip: '글씨 확대',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 페이지 번호 (하단)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_currentPage + 1} / ${_pages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),

        // 읽기 완료 버튼 (마지막 페이지에서만 표시)
        if (isLastPage && !_isCompleted)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _completeReading,
                icon: const Icon(Icons.check_circle),
                label: const Text('읽기 완료'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                  shadowColor: Colors.black45,
                ),
              ),
            ),
          ),

        // 완료 메시지
        if (_isCompleted)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '읽기 완료!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPageContent(int index) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            32, // 좌
            32, // 상 - AppBar가 오버레이되므로 일정하게 유지
            32, // 우
            120, // 하 - 페이지 번호와 버튼 공간
          ),
          child: Text(
            _pages[index],
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.9,
              color: const Color(0xFF2C1810),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeReading() {
    setState(() {
      _isCompleted = true;
    });

    // Supabase에 읽기 완료 상태 저장
    final user = ref.read(currentUserProvider);
    if (user != null) {
      SupabaseService.instance.client.from('reading_progress').upsert({
        'user_id': user.id,
        'story_id': widget.storyId,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }

    // 3초 후 자동으로 뒤로 가기
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _splitPages(BuildContext context, dynamic story, String bodyAr) {
    final size = MediaQuery.of(context).size;
    final textStyle = TextStyle(fontSize: _fontSize, height: 1.9, letterSpacing: 0.3);

    // intro + body + commentary 조합
    final fullContent = story.getFullContent(bodyAr);

    final pages = PageSplitter.splitIntoPages(
      text: fullContent,
      pageSize: size,
      textStyle: textStyle,
      textDirection: TextDirection.rtl,
    );

    if (mounted) {
      setState(() {
        _pages = pages;
        _currentPage = 0;
      });
    }
  }

  Widget _buildNotFound(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8F0),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: const Color(0xFF8B4513).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                '작품을 찾을 수 없습니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedState(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8F0),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: const Color(0xFF8B4513).withValues(alpha: 0.7),
                ),
                const SizedBox(height: 32),
                const Text(
                  '잠긴 작품',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '이 작품을 읽으려면\n컬렉션을 구매해야 합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF2C1810).withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      color: const Color(0xFFFFF8F0),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  '작품을 불러오는 중\n오류가 발생했습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: const Color(0xFF2C1810).withOpacity(0.6)),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
