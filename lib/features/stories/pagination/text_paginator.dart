import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/reader_theme.dart';

class TextPaginator {
  final String text;
  final ReaderThemeData theme;
  final BuildContext context;
  int _jobId = 0;
  final Function(int) onProgress;

  TextPaginator({
    required this.text,
    required this.theme,
    required this.context,
    required this.onProgress,
  });

  void cancel() {
    _jobId++;
  }

  Future<List<String>> paginate() async {
    final job = ++_jobId;
    final dims = _pageDims(context, theme);
    final style = TextStyle(fontSize: theme.fontSize, height: theme.lineHeight, letterSpacing: 0.3);
    final painter = TextPainter(textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: null);

    final base = _roughCharsPerPage(theme: theme, width: dims.width, height: dims.height).round();
    final newPages = <String>[];
    int cursor = 0;

    while (cursor < text.length) {
      if (job != _jobId) return [];

      final remaining = text.substring(cursor);
      final hi = math.min(remaining.length, math.max(400, (base * 2)));
      final cut = _fitCutIndexBounded(
        job: job,
        painter: painter,
        text: remaining,
        style: style,
        maxWidth: dims.width,
        maxHeight: dims.height,
        hi: hi,
      );

      if (job != _jobId) return [];

      final end = (cut <= 0) ? math.min(remaining.length, math.max(400, base)) : cut;
      newPages.add(remaining.substring(0, end).trimRight());
      cursor += end;
      
      onProgress(newPages.length);

      await Future<void>.delayed(Duration.zero);
    }
    
    return newPages;
  }

  _PageDims _pageDims(BuildContext context, ReaderThemeData theme) {
    final size = MediaQuery.of(context).size;
    final padding = EdgeInsets.fromLTRB(theme.horizontalMargin, theme.verticalMargin, theme.horizontalMargin, 120);
    final w = size.width - padding.left - padding.right;
    final h = size.height - padding.top - padding.bottom - MediaQuery.of(context).padding.top;
    return _PageDims(width: w, height: h);
  }

  double _roughCharsPerPage({required ReaderThemeData theme, required double width, required double height}) {
    final charsPerLine = math.max(10.0, width / (0.55 * theme.fontSize));
    final linesPerPage = math.max(5.0, height / (theme.lineHeight * theme.fontSize));
    return charsPerLine * linesPerPage * 0.95;
  }
  
  int _fitCutIndexBounded({required int job, required TextPainter painter, required String text, required TextStyle style, required double maxWidth, required double maxHeight, required int hi}) {
    int lo = 0;
    int high = hi;
    int best = 0;

    while (lo <= high) {
      if (job != _jobId) return 0;

      final mid = (lo + high) >> 1;
      painter.text = TextSpan(text: text.substring(0, mid), style: style);
      painter.layout(maxWidth: maxWidth);

      if (painter.height <= maxHeight) {
        best = mid;
        lo = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    if (best <= 0) return 0;
    final cut = _lastBreak(text, best);
    return cut > 0 ? cut : best;
  }

  int _lastBreak(String text, int endExclusive) {
    final end = math.min(endExclusive, text.length);
    for (int i = end - 1; i >= math.max(0, end - 220); i--) {
      final c = text.codeUnitAt(i);
      if (c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09) return i + 1;
      final ch = text[i];
      if (ch == '،' || ch == '.' || ch == '!' || ch == '؟' || ch == '؛') return i + 1;
    }
    return 0;
  }
}

class _PageDims {
  final double width;
  final double height;
  const _PageDims({required this.width, required this.height});
}
