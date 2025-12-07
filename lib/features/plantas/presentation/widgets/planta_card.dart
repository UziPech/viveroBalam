import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/planta.dart';

/// Tarjeta visual de planta con foto grande y iconos de cuidado
class PlantaCard extends StatelessWidget {
  final Planta planta;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int index;

  const PlantaCard({
    super.key,
    required this.planta,
    this.onTap,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(planta.id),
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
              // FOTO GRANDE (100x100)
              _buildPhoto(),

              const Gap(AppDesign.space16),

              // INFORMACIÓN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        planta.nombre,
                        style: AppDesign.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(AppDesign.space4),

                      // Categoría
                      Text(
                        planta.categoria,
                        style: AppDesign.footnote,
                      ),
                      const Gap(AppDesign.space8),

                      // Iconos de cuidado (luz y riego)
                      Row(
                        children: [
                          _buildCareChip(planta.luzEmoji, planta.luzTexto),
                          const Gap(AppDesign.space8),
                          _buildCareChip(planta.riegoEmoji, planta.riegoTexto),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // PRECIO
              Padding(
                padding: const EdgeInsets.only(right: AppDesign.space16),
                child: Column(
                  children: [
                    Text(
                      '\$${planta.precio.toStringAsFixed(0)}',
                      style: AppDesign.price,
                    ),
                  ],
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

  /// Construye la foto de la planta con placeholder si no existe
  Widget _buildPhoto() {
    final hasPhoto = planta.fotoPath.isNotEmpty;
    final file = hasPhoto ? File(planta.fotoPath) : null;
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
            ? Image.file(
                file!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Placeholder cuando no hay foto
  Widget _buildPlaceholder() {
    return Container(
      color: AppDesign.gray100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_florist_rounded,
              size: 36,
              color: AppDesign.gray400,
            ),
            const Gap(AppDesign.space4),
            Text(
              planta.nombre.isNotEmpty ? planta.nombre[0].toUpperCase() : '🌱',
              style: AppDesign.caption,
            ),
          ],
        ),
      ),
    );
  }

  /// Chip pequeño para mostrar información de cuidado
  Widget _buildCareChip(String emoji, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.space8,
          vertical: AppDesign.space4,
        ),
        decoration: BoxDecoration(
          color: AppDesign.gray50,
          borderRadius: BorderRadius.circular(AppDesign.space8),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
