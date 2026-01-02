import 'package:flutter/material.dart';

/// 페이지 분할 유틸리티
class PageSplitter {
  /// 텍스트를 페이지 단위로 분할
  static List<String> splitIntoPages({
    required String text,
    required Size pageSize,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) {
    final List<String> pages = [];
    final textPainter = TextPainter(
      textDirection: textDirection,
      textAlign: TextAlign.right,
    );

    // 사용 가능한 높이 (여백 고려)
    const verticalPadding = 48.0; // 상하 여백
    const horizontalPadding = 32.0; // 좌우 여백
    final availableHeight = pageSize.height - verticalPadding;
    final availableWidth = pageSize.width - horizontalPadding;

    // 전체 텍스트를 단어 단위로 분할
    final words = text.split(' ');
    final buffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final testBuffer = StringBuffer(buffer.toString());

      if (testBuffer.isNotEmpty) {
        testBuffer.write(' ');
      }
      testBuffer.write(word);

      // 현재까지의 텍스트로 TextPainter 테스트
      textPainter.text = TextSpan(
        text: testBuffer.toString(),
        style: textStyle,
      );
      textPainter.layout(maxWidth: availableWidth);

      // 높이가 초과되면 현재 페이지 저장
      if (textPainter.height > availableHeight) {
        if (buffer.isEmpty) {
          // 단어가 너무 길어서 한 페이지에 들어가지 않는 경우
          pages.add(word);
          buffer.clear();
        } else {
          pages.add(buffer.toString().trim());
          buffer.clear();
          buffer.write(word);
        }
      } else {
        buffer.write(buffer.isEmpty ? word : ' $word');
      }
    }

    // 마지막 페이지 추가
    if (buffer.isNotEmpty) {
      pages.add(buffer.toString().trim());
    }

    return pages.isEmpty ? [''] : pages;
  }
}
