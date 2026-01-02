import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/core/theme/reader_theme.dart';
import 'package:k_lit/core/theme/reader_theme_provider.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';
import 'package:k_lit/features/stories/pagination/text_paginator.dart';
import 'package:k_lit/features/stories/providers/story_content_provider.dart';
import 'package:k_lit/features/stories/providers/story_provider.dart';
import 'package:k_lit/features/stories/widgets/story_reader/reader_app_bar.dart';
import 'package:k_lit/features/stories/widgets/story_reader/reader_error_widgets.dart';
import 'package:k_lit/features/stories/widgets/story_reader/reader_page_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryReaderPage extends ConsumerStatefulWidget {
  final String collectionId;
  final String storyId;
  const StoryReaderPage({super.key, required this.collectionId, required this.storyId});

  @override
  ConsumerState<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends ConsumerState<StoryReaderPage> {
  late final PageController _pageController;
  TextPaginator? _paginator;

  bool _showControls = false;

  late ReaderThemeData _displayTheme;

  int _currentPage = 0;
  List<String> _pages = <String>[];
  int? _estimatedTotalPages;

  bool _isPaginating = false;
  bool _paginationDone = false;
  Timer? _debounce;
  Timer? _saveProgressDebounce;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _displayTheme = ref.read(readerThemeProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadReadingProgress();
    _pageController = PageController(initialPage: _currentPage);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _saveProgressDebounce?.cancel();
    _paginator?.cancel();
    if (_isInitialized) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: _displayTheme.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
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
          if (story == null) {
            return ReaderErrorWidgets.buildNotFound(context, _displayTheme);
          }

          final hasEntitlement = ref.watch(collectionPurchasedProvider(widget.collectionId));

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
                if (!mounted) {
                  return;
                }
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

    final fullText = ref
        .read(storyContentProvider(widget.storyId))
        .when(
          data: (content) {
            final story = ref.read(storyProvider(widget.storyId)).value;
            return story?.getFullContent(content.bodyAr) ?? '';
          },
          loading: () => '',
          error: (e, s) => '',
        );

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (fullText.isNotEmpty) {
        _startPaginate(fullText, keepIndex: _currentPage);
      }
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

  Future<void> _loadReadingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('story_${widget.storyId}_last_page');
    if (savedPage != null) {
      setState(() {
        _currentPage = savedPage;
      });
    }
  }

  void _saveReadingProgress(int page) {
    _saveProgressDebounce?.cancel();
    _saveProgressDebounce = Timer(const Duration(seconds: 1), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('story_${widget.storyId}_last_page', page);
    });
  }

  Widget _buildReader(BuildContext context) {
    final hasPages = _pages.isNotEmpty;
    final totalLabel = _paginationDone
        ? _pages.length.toString()
        : (_estimatedTotalPages?.toString() ?? '?');

    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: PageView.builder(
            controller: _pageController,
            itemCount: math.max(1, _pages.length),
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _saveReadingProgress(i);
            },
            itemBuilder: (context, index) {
              if (_pages.isEmpty) {
                return Center(child: CircularProgressIndicator(color: _displayTheme.textColor));
              }
              return ReaderPageContent(pageText: _pages[index], theme: _displayTheme);
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(onTap: _previousPage, behavior: HitTestBehavior.translucent),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Expanded(
              child: GestureDetector(onTap: _nextPage, behavior: HitTestBehavior.translucent),
            ),
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
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.7).round()),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '${_currentPage + 1} / $totalLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
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
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.55).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('reflow...', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
      ],
    );
  }

  void _nextPage() {
    if (_pages.isEmpty) return;
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }
}
