import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/planta.dart';

/// Modal de detalle de planta responsive con imagen grande
class PlantaDetailModal extends StatelessWidget {
  final Planta planta;

  const PlantaDetailModal({super.key, required this.planta});

  /// Muestra el modal de detalle
  static void show(BuildContext context, Planta planta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlantaDetailModal(planta: planta),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // Máximo 85% de pantalla

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppDesign.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesign.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: AppDesign.space12),
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppDesign.gray300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Contenido scrolleable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesign.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen grande
                  _buildImage(context),
                  const Gap(AppDesign.space20),

                  // Nombre y categoría
                  _buildHeader(),
                  const Gap(AppDesign.space16),

                  // Precio
                  _buildPrice(),
                  const Gap(AppDesign.space20),

                  // Características (luz y riego)
                  _buildCareInfo(),
                  const Gap(AppDesign.space20),

                  // Fecha de registro
                  _buildMetadata(),
                  const Gap(AppDesign.space32),

                  // Botón cerrar
                  _buildCloseButton(context),
                  const Gap(AppDesign.space16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Imagen grande con aspect ratio y placeholder
  Widget _buildImage(BuildContext context) {
    final hasPhoto = planta.fotoPath.isNotEmpty;
    final file = hasPhoto ? File(planta.fotoPath) : null;
    final photoExists = file?.existsSync() ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
      child: AspectRatio(
        aspectRatio: 4 / 3, // Ratio de imagen
        child: Container(
          width: double.infinity,
          color: AppDesign.gray100,
          child: photoExists
              ? GestureDetector(
                  onTap: () => _showFullImage(context, file!),
                  child: Image.file(
                    file!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                )
              : _buildPlaceholder(),
        ),
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
              size: 64,
              color: AppDesign.gray400,
            ),
            const Gap(AppDesign.space8),
            Text(
              "Sin imagen",
              style: AppDesign.caption,
            ),
          ],
        ),
      ),
    );
  }

  /// Encabezado con nombre y categoría
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          planta.nombre,
          style: AppDesign.title1,
        ),
        const Gap(AppDesign.space4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space12,
            vertical: AppDesign.space4,
          ),
          decoration: BoxDecoration(
            color: AppDesign.gray100,
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
          child: Text(
            planta.categoria,
            style: AppDesign.footnote,
          ),
        ),
      ],
    );
  }

  /// Precio grande
  Widget _buildPrice() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: AppDesign.gray50,
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money_rounded,
            color: AppDesign.gray500,
            size: 24,
          ),
          const Gap(AppDesign.space8),
          Text(
            '\$${planta.precio.toStringAsFixed(2)}',
            style: AppDesign.title2.copyWith(
              color: AppDesign.gray900,
            ),
          ),
          const Spacer(),
          Text(
            "Precio de venta",
            style: AppDesign.footnote,
          ),
        ],
      ),
    );
  }

  /// Información de cuidados
  Widget _buildCareInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Cuidados", style: AppDesign.bodyBold),
        const Gap(AppDesign.space12),
        Row(
          children: [
            Expanded(child: _buildCareCard("Luz", planta.luzEmoji, planta.luzTexto)),
            const Gap(AppDesign.space12),
            Expanded(child: _buildCareCard("Riego", planta.riegoEmoji, planta.riegoTexto)),
          ],
        ),
      ],
    );
  }

  /// Tarjeta de cuidado individual
  Widget _buildCareCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: AppDesign.gray50,
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        border: Border.all(color: AppDesign.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const Gap(AppDesign.space8),
              Text(title, style: AppDesign.footnote),
            ],
          ),
          const Gap(AppDesign.space8),
          Text(
            description,
            style: AppDesign.bodyBold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Metadatos (fecha de registro)
  Widget _buildMetadata() {
    final fecha = planta.createdAt;
    final fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined, size: 16, color: AppDesign.gray400),
        const Gap(AppDesign.space8),
        Text(
          "Registrada el $fechaFormateada",
          style: AppDesign.footnote,
        ),
      ],
    );
  }

  /// Botón para cerrar
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppDesign.gray900,
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        ),
        child: Center(
          child: Text(
            "Cerrar",
            style: AppDesign.bodyBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Muestra la imagen en pantalla completa
  void _showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppDesign.space16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
