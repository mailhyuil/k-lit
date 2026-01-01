import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/config/supabase_client.dart';
import 'package:flutter_application_1/core/theme/reader_theme.dart';
import 'package:flutter_application_1/core/theme/reader_theme_provider.dart';
import 'package:flutter_application_1/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_1/features/entitlements/providers/entitlement_provider.dart';
import 'package:flutter_application_1/features/stories/pagination/text_paginator.dart';
import 'package:flutter_application_1/features/stories/providers/story_content_provider.dart';
import 'package:flutter_application_1/features/stories/providers/story_provider.dart';
import 'package:flutter_application_1/features/stories/widgets/story_reader/reader_app_bar.dart';
import 'package:flutter_application_1/features/stories/widgets/story_reader/reader_error_widgets.dart';
import 'package:flutter_application_1/features/stories/widgets/story_reader/reader_page_content.dart';

class StoryReaderPage extends ConsumerStatefulWidget {
  final String storyId;
  const StoryReaderPage({super.key, required this.storyId});

  @override
  ConsumerState<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends ConsumerState<StoryReaderPage> {
  late final PageController _pageController;
  TextPaginator? _paginator;

  bool _showControls = false;
  bool _isCompleted = false;

  late ReaderThemeData _displayTheme;

  int _currentPage = 0;
  List<String> _pages = <String>[];
  int? _estimatedTotalPages;

  bool _isPaginating = false;
  bool _paginationDone = false;
  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    _displayTheme = ref.read(readerThemeProvider);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _paginator?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReaderThemeData>(readerThemeProvider, (previous, next) {
      _onThemeChange(next);
    });

    final storyAsync = ref.watch(storyProvider(widget.storyId));

    return Scaffold(
      backgroundColor: _displayTheme.backgroundColor,
      body: storyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ReaderErrorWidgets.buildErrorState(context, e, _displayTheme),
        data: (story) {
          if (story == null) return ReaderErrorWidgets.buildNotFound(context, _displayTheme);

          final entAsync = ref.watch(hasEntitlementByStoryIdProvider(widget.storyId));
          final hasEntitlement = entAsync.value ?? false;

          if (story.isLocked && !story.isFree && !hasEntitlement) {
            return ReaderErrorWidgets.buildLockedState(context, _displayTheme);
          }

          final contentAsync = ref.watch(storyContentProvider(widget.storyId));
          return contentAsync.when(
            loading: () => ReaderErrorWidgets.buildContentLoading(_displayTheme),
            error: (e, _) => ReaderErrorWidgets.buildContentError(e, _displayTheme),
            data: (storyContent) {
              final fullText = story.getFullContent(storyContent.bodyAr);
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (_pages.isEmpty && !_isPaginating) {
                  _startPaginate(fullText, keepIndex: _currentPage);
                }
              });

              return _buildReader(context);
            },
          );
        },
      ),
    );
  }

  void _onThemeChange(ReaderThemeData newTheme) {
    if (newTheme == _displayTheme) return;

    setState(() {
      _displayTheme = newTheme;
    });

    _paginator?.cancel();

    final fullText = ref.read(storyContentProvider(widget.storyId)).when(
      data: (content) {
        final story = ref.read(storyProvider(widget.storyId)).value;
        return story?.getFullContent(content.bodyAr) ?? '';
      },
      loading: () => '',
      error: (e, s) => '',
    );
    
    if (fullText.isEmpty) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _startPaginate(fullText, keepIndex: _currentPage);
    });
  }

  Future<void> _startPaginate(String fullText, {required int keepIndex}) async {
    if (_isPaginating) return;
    setState(() {
      _isPaginating = true;
      _paginationDone = false;
    });

    _paginator = TextPaginator(
      text: _processText(fullText, _displayTheme),
      theme: _displayTheme,
      context: context,
      onProgress: (pageCount) {
        setState(() {
          _estimatedTotalPages = pageCount;
        });
      },
    );

    final newPages = await _paginator!.paginate();
    
    if (!mounted) return;

    setState(() {
      _pages = newPages;
      _paginationDone = true;
      _isPaginating = false;
      _currentPage = math.min(keepIndex, math.max(0, _pages.length - 1));
      _estimatedTotalPages = _pages.length;
    });

    if (_pageController.hasClients && _pageController.page?.round() != _currentPage) {
      _pageController.jumpToPage(_currentPage);
    }
  }

  String _processText(String text, ReaderThemeData theme) {
    if (theme.paragraphSpacing <= 0) {
      return text;
    }
    final extraNewlines = '\n' * theme.paragraphSpacing.round();
    return text.replaceAll('\n', '\n$extraNewlines');
  }

  Widget _buildReader(BuildContext context) {
    final hasPages = _pages.isNotEmpty;
    final totalLabel = _paginationDone ? _pages.length.toString() : (_estimatedTotalPages?.toString() ?? '?');
    final isLastPage = _paginationDone && hasPages && _currentPage == _pages.length - 1;

    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: PageView.builder(
            controller: _pageController,
            itemCount: math.max(1, _pages.length),
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              if (_pages.isEmpty) {
                return Center(child: CircularProgressIndicator(color: _displayTheme.textColor));
              }
              return _PageTurn(
                controller: _pageController,
                index: index,
                child: ReaderPageContent(pageText: _pages[index], theme: _displayTheme),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(child: GestureDetector(onTap: _previousPage, behavior: HitTestBehavior.translucent)),
            Expanded(child: GestureDetector(onTap: () => setState(() => _showControls = !_showControls), behavior: HitTestBehavior.translucent)),
            Expanded(child: GestureDetector(onTap: _nextPage, behavior: HitTestBehavior.translucent)),
          ],
        ),
        if (_showControls) const ReaderAppBar(),
        if (hasPages)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.black.withAlpha((255 * 0.7).round()), borderRadius: BorderRadius.circular(24)),
              child: Text(
                '${_currentPage + 1} / $totalLabel',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        if (_isPaginating)
          Positioned(
            top: 90,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withAlpha((255 * 0.55).round()), borderRadius: BorderRadius.circular(12)),
              child: const Text('reflow...', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
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
                style: ElevatedButton.styleFrom(backgroundColor: _displayTheme.textColor, foregroundColor: _displayTheme.backgroundColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              ),
            ),
          ),
        if (_isCompleted)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(24)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('읽기 완료!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _nextPage() {
    if (_pages.isEmpty) return;
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  void _completeReading() {
    setState(() => _isCompleted = true);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      SupabaseService.instance.client.from('reading_progress').upsert({
        'user_id': user.id,
        'story_id': widget.storyId,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}

class _PageTurn extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;
  const _PageTurn({required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double page = 0.0;
        try {
          page = controller.hasClients ? (controller.page ?? controller.initialPage.toDouble()) : 0.0;
        } catch (_) {
          page = 0.0;
        }
        final delta = (page - index).clamp(-1.0, 1.0);
        final angle = delta * 0.6;

        return Transform(
          alignment: delta > 0 ? Alignment.centerLeft : Alignment.centerRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: child,
        );
      },
    );
  }
}
