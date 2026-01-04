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
      child: Column(
        children: [
          Text(story.titleAr),
          Text(story.introAr ?? ''),
          Text(story.commentaryAr ?? ''),
          ElevatedButton(
            onPressed: () => purchaseController.handlePurchase(context, collection),
            child: const Text('구매하기'),
          ),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
        ],
      ),
    );
  }
}
