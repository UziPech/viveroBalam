import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/artesania.dart';

/// Tarjeta visual de artesanía con foto y dimensiones
class ArtesaniaCard extends StatelessWidget {
  final Artesania artesania;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const ArtesaniaCard({
    super.key,
    required this.artesania,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(artesania.id),
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
          decoration: AppDesign.cardDecoration,
          child: Row(
            children: [
              // FOTO (100x100)
              _buildPhoto(),
              const Gap(AppDesign.space16),

              // INFORMACIÓN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artesania.nombre,
                        style: AppDesign.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(AppDesign.space4),
                      Text(artesania.categoria, style: AppDesign.footnote),
                      const Gap(AppDesign.space8),
                      // Dimensiones
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.space8,
                          vertical: AppDesign.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesign.gray50,
                          borderRadius: BorderRadius.circular(AppDesign.space8),
                        ),
                        child: Text(
                          '📐 ${artesania.dimensiones}',
                          style: AppDesign.footnote.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PRECIO
              Padding(
                padding: const EdgeInsets.only(right: AppDesign.space16),
                child: Text(
                  '\$${artesania.precio.toStringAsFixed(0)}',
                  style: AppDesign.price,
                ),
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

  Widget _buildPhoto() {
    final hasPhoto = artesania.fotoPath.isNotEmpty;
    final file = hasPhoto ? File(artesania.fotoPath) : null;
    final photoExists = file?.existsSync() ?? false;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppDesign.radiusLarge),
        bottomLeft: Radius.circular(AppDesign.radiusLarge),
      ),
      child: Container(
        width: 100,
        height: 100,
        color: AppDesign.gray100,
        child: photoExists
            ? Image.file(file!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppDesign.gray100,
      child: const Center(
        child: Icon(Icons.emoji_objects_rounded, size: 36, color: AppDesign.gray400),
      ),
    );
  }
}
