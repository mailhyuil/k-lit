import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_lit/features/collections/models/collection.dart';
import 'package:k_lit/features/purchase/providers/purchase_provider.dart';
import 'package:k_lit/features/stories/models/story.dart';

class StoryDetailDialog extends ConsumerWidget {
  final Story story;
  final Collection collection;
  const StoryDetailDialog({super.key, required this.story, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseController = ref.read(purchaseControllerProvider.notifier);
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [Text('Story Detail'), Text(story.titleAr)]),
            SizedBox(height: 16),
            Column(children: [Text('Story Intro'), Text(story.introAr ?? '')]),
            SizedBox(height: 16),
            Column(children: [Text('Story Commentary'), Text(story.commentaryAr ?? '')]),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => purchaseController.handlePurchase(context, collection),
                    child: const Text('구매하기'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
