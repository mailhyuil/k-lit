import 'package:flutter/material.dart';

import '../models/collection.dart';

/// 컬렉션 카드 위젯
class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback? onTap;

  const CollectionCard({super.key, required this.collection, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 커버 이미지
            Expanded(flex: 3, child: _buildCover()),
            // 정보 영역
            Expanded(flex: 2, child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (collection.coverUrl != null) {
      return Image.network(
        collection.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(),
      );
    }
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.collections_bookmark, size: 48, color: Colors.grey.shade400),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목 (아랍어)
          Flexible(
            child: Text(
              collection.titleAr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 4),

          // 작품 수
          Text(
            '${collection.storyCount}개 작품',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),

          // 상태 뱃지
          Wrap(
            spacing: 4,
            children: [
              if (collection.isFree) _buildFreeBadge(),
              if (collection.isPurchased && !collection.isFree) _buildPurchasedBadge(),
              if (!collection.isPurchased && !collection.isFree) _buildPriceBadge(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '무료',
        style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPurchasedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '구매완료',
        style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPriceBadge(BuildContext context) {
    final price = _getPriceLabel();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        price,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getPriceLabel() {
    switch (collection.priceTier) {
      case 'tier1':
        return '\$2.99';
      case 'tier2':
        return '\$4.99';
      case 'tier3':
        return '\$9.99';
      default:
        return '유료';
    }
  }
}
