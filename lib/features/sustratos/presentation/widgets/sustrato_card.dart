import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/sustrato.dart';

/// Tarjeta visual de sustrato con foto y cantidad
class SustratoCard extends StatelessWidget {
  final Sustrato sustrato;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const SustratoCard({
    super.key,
    required this.sustrato,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(sustrato.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding, vertical: AppDesign.space8),
        decoration: BoxDecoration(color: AppDesign.accentError, borderRadius: BorderRadius.circular(AppDesign.radiusLarge)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDesign.space24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding, vertical: AppDesign.space8),
          decoration: AppDesign.cardDecoration,
          child: Row(
            children: [
              _buildPhoto(),
              const Gap(AppDesign.space16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sustrato.nombre, style: AppDesign.bodyBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Gap(AppDesign.space4),
                      Text(sustrato.categoria, style: AppDesign.footnote),
                      // Stock indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space8, vertical: AppDesign.space4),
                        decoration: BoxDecoration(
                          color: sustrato.agotado ? AppDesign.accentError.withAlpha(20) : 
                                 sustrato.stockBajo ? AppDesign.accentWarning.withAlpha(20) : 
                                 AppDesign.gray50,
                          borderRadius: BorderRadius.circular(AppDesign.space8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: sustrato.agotado ? AppDesign.accentError : 
                                     sustrato.stockBajo ? AppDesign.accentWarning : 
                                     AppDesign.gray500,
                            ),
                            const Gap(4),
                            Text(
                              '${sustrato.cantidad}',
                              style: AppDesign.footnote.copyWith(
                                fontSize: 12,
                                color: sustrato.agotado ? AppDesign.accentError : 
                                       sustrato.stockBajo ? AppDesign.accentWarning : 
                                       AppDesign.gray700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppDesign.space16),
                child: Text('\$${sustrato.precio.toStringAsFixed(0)}', style: AppDesign.price),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 40 * index)).fadeIn(duration: 300.ms).slideX(begin: 0.02, end: 0);
  }

  Widget _buildPhoto() {
    final file = sustrato.fotoPath.isNotEmpty ? File(sustrato.fotoPath) : null;
    final photoExists = file?.existsSync() ?? false;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppDesign.radiusLarge), bottomLeft: Radius.circular(AppDesign.radiusLarge)),
      child: Container(
        width: 100, height: 100,
        color: AppDesign.gray100,
        child: photoExists
            ? Image.file(file!, fit: BoxFit.cover)
            : const Center(child: Icon(Icons.grass_rounded, size: 36, color: AppDesign.gray400)),
      ),
    );
  }
}
