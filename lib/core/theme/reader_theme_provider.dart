import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reader_theme.dart';

final readerThemeProvider = NotifierProvider<ReaderThemeNotifier, ReaderThemeData>(ReaderThemeNotifier.new);

class ReaderThemeNotifier extends Notifier<ReaderThemeData> {
  static const _prefsKey = 'reader_theme';

  @override
  ReaderThemeData build() {
    _load();
    return ReaderThemeData.defaultTheme();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        state = ReaderThemeData.fromJson(json.decode(jsonString));
      } catch (e) {
        state = ReaderThemeData.defaultTheme();
      }
    } else {
      state = ReaderThemeData.defaultTheme();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.toJson());
    await prefs.setString(_prefsKey, jsonString);
  }

  void updateTheme(ReaderThemeData theme) {
    state = theme;
    _save();
  }

  void updateFontSize(double size) {
    state = state.copyWith(fontSize: size);
    _save();
  }

  void updateLineHeight(double height) {
    state = state.copyWith(lineHeight: height);
    _save();
  }

  void updateParagraphSpacing(double spacing) {
    state = state.copyWith(paragraphSpacing: spacing);
    _save();
  }

  void updateVerticalMargin(double margin) {
    state = state.copyWith(verticalMargin: margin);
    _save();
  }
  
  void updateHorizontalMargin(double margin) {
    state = state.copyWith(horizontalMargin: margin);
    _save();
  }

  void updateBackgroundColor(Color color) {
    Color textColor;
    if (color.toARGB32() == const Color(0xFFFFF8F0).toARGB32()) {
      textColor = const Color(0xFF2C1810); // Paper
    } else if (color.toARGB32() == const Color(0xFFFBF0D9).toARGB32()) {
      textColor = const Color(0xFF5B4636); // Sepia
    } else if (color.toARGB32() == const Color(0xFF121212).toARGB32()) {
      textColor = const Color(0xFFE0E0E0); // Night
    } else {
      textColor = state.textColor;
    }
    state = state.copyWith(backgroundColor: color, textColor: textColor);
    _save();
  }
}
