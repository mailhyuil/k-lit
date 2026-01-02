import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/core/theme/reader_theme.dart';
import 'package:k_lit/core/theme/reader_theme_provider.dart';

class StoryReaderSettings extends ConsumerWidget {
  const StoryReaderSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(readerThemeProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Text'),
            _buildSliderRow(
              'Font Size',
              theme.fontSize,
              12,
              36,
              (v) => ref.read(readerThemeProvider.notifier).updateFontSize(v),
            ),
            _buildSliderRow(
              'Line Spacing',
              theme.lineHeight,
              1.2,
              2.5,
              (v) => ref.read(readerThemeProvider.notifier).updateLineHeight(v),
            ),
            _buildSliderRow(
              'Paragraph Spacing',
              theme.paragraphSpacing,
              0.5,
              3.0,
              (v) => ref
                  .read(readerThemeProvider.notifier)
                  .updateParagraphSpacing(v),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Margins'),
            _buildSliderRow(
              'Vertical',
              theme.verticalMargin,
              0,
              100,
              (v) => ref
                  .read(readerThemeProvider.notifier)
                  .updateVerticalMargin(v),
            ),
            _buildSliderRow(
              'Horizontal',
              theme.horizontalMargin,
              0,
              100,
              (v) => ref
                  .read(readerThemeProvider.notifier)
                  .updateHorizontalMargin(v),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Page Color'),
            _buildColorSelector(theme, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt() * 2,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildColorSelector(ReaderThemeData theme, WidgetRef ref) {
    const colors = {
      'Paper': Color(0xFFFFF8F0),
      'Sepia': Color(0xFFFBF0D9),
      'Night': Color(0xFF121212),
    };

    return Wrap(
      spacing: 16,
      children: colors.entries.map((entry) {
        final colorName = entry.key;
        final color = entry.value;
        final isSelected = theme.backgroundColor.toARGB32() == color.toARGB32();

        return ChoiceChip(
          label: Text(colorName),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref
                  .read(readerThemeProvider.notifier)
                  .updateBackgroundColor(color);
            }
          },
          avatar: CircleAvatar(backgroundColor: color),
        );
      }).toList(),
    );
  }
}
