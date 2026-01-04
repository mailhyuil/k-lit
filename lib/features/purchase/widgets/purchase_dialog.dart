import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../collections/models/collection.dart';
import '../providers/purchase_provider.dart';

/// 구매 다이얼로그
class PurchaseDialog extends ConsumerWidget {
  final Collection collection;
  const PurchaseDialog({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final offerings = purchaseState.offerings;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.collections_bookmark, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    collection.titleAr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 설명
                  if (collection.descriptionAr?.isNotEmpty ?? false)
                    Text(
                      collection.descriptionAr!,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // 상품 목록
                  if (purchaseState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (offerings == null || offerings.all.isEmpty)
                    _buildNoProducts(context)
                  else
                    _buildProductList(context, ref, offerings),

                  // 에러 메시지
                  if (purchaseState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              purchaseState.error!,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: purchaseState.isLoading
                          ? null
                          : () => _restorePurchases(context, ref),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('복원'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProducts(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('사용 가능한 상품이 없습니다', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }

  Widget _buildProductList(BuildContext context, WidgetRef ref, Offerings offerings) {
    // 현재 offering 가져오기 (첫 번째 것 사용)
    final offering = offerings.current;
    if (offering == null || offering.availablePackages.isEmpty) {
      return _buildNoProducts(context);
    }

    // 컬렉션 ID에 맞는 패키지 필터링
    final packages = offering.availablePackages.where((package) {
      return package.storeProduct.identifier == collection.rcIdentifier;
    }).toList();

    if (packages.isEmpty) {
      return _buildNoProducts(context);
    }

    return Column(
      children: packages.map((package) {
        return _buildProductCard(context, ref, package);
      }).toList(),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, Package package) {
    final product = package.storeProduct;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchase(context, ref, package),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.priceString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref, Package package) async {
    final controller = ref.read(purchaseControllerProvider.notifier);
    final success = await controller.purchase(package);

    if (success && context.mounted) {
      // TODO: purchase_provider에서 getCustomerInfo / purchasePackage를 통해서 권한 확인 후 UI 다시 그리기

      Navigator.of(context).pop(true); // 구매 성공 결과 반환

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구매가 완료되었습니다!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(purchaseControllerProvider.notifier);
    final success = await controller.restoreCustomerInfo();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구매 복원이 완료되었습니다!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
