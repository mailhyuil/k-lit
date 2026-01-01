import 'dart:ui';

import 'package:flutter/material.dart';

class ReaderThemeData {
  final double fontSize;
  final double lineHeight;
  final double paragraphSpacing;
  final double verticalMargin;
  final double horizontalMargin;
  final Color backgroundColor;
  final Color textColor;

  const ReaderThemeData({
    required this.fontSize,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.verticalMargin,
    required this.horizontalMargin,
    required this.backgroundColor,
    required this.textColor,
  });

  factory ReaderThemeData.defaultTheme() {
    return const ReaderThemeData(
      fontSize: 18.0,
      lineHeight: 1.9,
      paragraphSpacing: 1.0, // Multiplier for line height
      verticalMargin: 32.0,
      horizontalMargin: 32.0,
      backgroundColor: Color(0xFFFFF8F0),
      textColor: Color(0xFF2C1810),
    );
  }

  ReaderThemeData copyWith({
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? verticalMargin,
    double? horizontalMargin,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ReaderThemeData(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      verticalMargin: verticalMargin ?? this.verticalMargin,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'paragraphSpacing': paragraphSpacing,
      'verticalMargin': verticalMargin,
      'horizontalMargin': horizontalMargin,
      'backgroundColor': backgroundColor.toARGB32(),
      'textColor': textColor.toARGB32(),
    };
  }

  factory ReaderThemeData.fromJson(Map<String, dynamic> json) {
    return ReaderThemeData(
      fontSize: json['fontSize'] ?? 18.0,
      lineHeight: json['lineHeight'] ?? 1.9,
      paragraphSpacing: json['paragraphSpacing'] ?? 1.0,
      verticalMargin: json['verticalMargin'] ?? 32.0,
      horizontalMargin: json['horizontalMargin'] ?? 32.0,
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFF8F0),
      textColor: Color(json['textColor'] ?? 0xFF2C1810),
    );
  }
}
