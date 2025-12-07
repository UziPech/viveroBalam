import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/product.dart';

/// Tarjeta de producto estilo Apple monocromático
class ProductCardModern extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const ProductCardModern({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.currentStock <= product.minStock;

    return Dismissible(
      key: Key(product.key.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDesign.screenPadding,
          vertical: AppDesign.space8,
        ),
        decoration: BoxDecoration(
          color: AppDesign.accentError,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDesign.space24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDesign.screenPadding,
            vertical: AppDesign.space8,
          ),
          padding: const EdgeInsets.all(AppDesign.space16),
          decoration: AppDesign.cardDecoration,
          child: Row(
            children: [
              // Avatar monocromático
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppDesign.gray900,
                  borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                    style: AppDesign.title3.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const Gap(AppDesign.space16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppDesign.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(AppDesign.space4),
                    Text(product.category, style: AppDesign.footnote),
                  ],
                ),
              ),

              // Precio y Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.salePrice.toStringAsFixed(2)}',
                    style: AppDesign.price,
                  ),
                  const Gap(AppDesign.space4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesign.space8,
                      vertical: AppDesign.space4,
                    ),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? AppDesign.accentWarning.withAlpha(20)
                          : AppDesign.gray100,
                      borderRadius: BorderRadius.circular(AppDesign.space8),
                    ),
                    child: Text(
                      '${product.currentStock}',
                      style: AppDesign.footnote.copyWith(
                        color: isLowStock ? AppDesign.accentWarning : AppDesign.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 40 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.02, end: 0, curve: Curves.easeOut);
  }
}
