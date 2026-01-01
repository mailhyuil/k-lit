import 'package:flutter/material.dart';
import 'package:k_lit/core/theme/reader_theme.dart';

class ReaderPageContent extends StatelessWidget {
  final String pageText;
  final ReaderThemeData theme;

  const ReaderPageContent({super.key, required this.pageText, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            theme.horizontalMargin,
            theme.verticalMargin,
            theme.horizontalMargin,
            120,
          ),
          child: Text(
            pageText,
            style: TextStyle(
              fontSize: theme.fontSize,
              height: theme.lineHeight,
              color: theme.textColor,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}
