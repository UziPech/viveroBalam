import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/sustrato.dart';

/// Modal de detalle de sustrato
class SustratoDetailModal extends StatelessWidget {
  final Sustrato sustrato;

  const SustratoDetailModal({super.key, required this.sustrato});

  static void show(BuildContext context, Sustrato sustrato) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SustratoDetailModal(sustrato: sustrato),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(color: AppDesign.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radiusXL))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDesign.space12),
            child: Container(width: 36, height: 5, decoration: BoxDecoration(color: AppDesign.gray300, borderRadius: BorderRadius.circular(3))),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesign.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  const Gap(AppDesign.space20),
                  Text(sustrato.nombre, style: AppDesign.title1),
                  const Gap(AppDesign.space4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDesign.space12, vertical: AppDesign.space4),
                    decoration: BoxDecoration(color: AppDesign.gray100, borderRadius: BorderRadius.circular(AppDesign.radiusSmall)),
                    child: Text(sustrato.categoria, style: AppDesign.footnote),
                  ),
                  const Gap(AppDesign.space16),
                  _buildInfoRow("💰 Precio", '\$${sustrato.precio.toStringAsFixed(2)}'),
                  const Gap(AppDesign.space12),
                  _buildInfoRow("${sustrato.stockEmoji} Stock", '${sustrato.cantidad} unidades'),
                  if (sustrato.descripcion.isNotEmpty) ...[
                    const Gap(AppDesign.space16),
                    const Text("Descripción", style: AppDesign.bodyBold),
                    const Gap(AppDesign.space8),
                    Text(sustrato.descripcion, style: AppDesign.body),
                  ],
                  const Gap(AppDesign.space24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(color: AppDesign.gray900, borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
                      child: Center(child: Text("Cerrar", style: AppDesign.bodyBold.copyWith(color: Colors.white))),
                    ),
                  ),
                  const Gap(AppDesign.space16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final file = sustrato.fotoPath.isNotEmpty ? File(sustrato.fotoPath) : null;
    final photoExists = file?.existsSync() ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: AppDesign.gray100,
          child: photoExists ? Image.file(file!, fit: BoxFit.cover) : const Center(child: Icon(Icons.grass_rounded, size: 64, color: AppDesign.gray400)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(color: AppDesign.gray50, borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppDesign.footnote), Text(value, style: AppDesign.bodyBold)]),
    );
  }
}
