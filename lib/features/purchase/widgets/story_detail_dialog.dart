import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_lit/features/collections/models/collection.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';
import 'package:k_lit/features/stories/models/story.dart';
import 'package:k_lit/l10n/app_localizations.dart';

class StoryDetailDialog extends ConsumerWidget {
  final Story story;
  final Collection collection;
  const StoryDetailDialog({
    super.key,
    required this.story,
    required this.collection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseController = ref.read(purchaseControllerProvider.notifier);
    final t = AppLocalizations.of(context)!;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                Text(
                  t.storyTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  story.titleAr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 16),
                Column(
                  children: [Text(t.storyIntro), Text(story.introAr ?? '')],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    Text(t.storyCommentary),
                    Text(story.commentaryAr ?? ''),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                          purchaseController.handlePurchase(
                            context,
                            collection,
                          );
                        },
                        child: Text(t.buy),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: Text(t.cancel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
