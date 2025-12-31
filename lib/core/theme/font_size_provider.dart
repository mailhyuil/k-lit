import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(FontSizeNotifier.new);

class FontSizeNotifier extends Notifier<double> {
  static const _defaultFontSize = 16.0;
  static const _prefsKey = 'font_size';

  @override
  double build() {
    _load();
    return _defaultFontSize;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_prefsKey) ?? _defaultFontSize;
  }

  Future<void> setFontSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, size);
  }
}
