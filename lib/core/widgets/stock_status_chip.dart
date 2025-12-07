import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Chip indicador de estado de stock
enum StockStatus { ok, low, critical }

class StockStatusChip extends StatelessWidget {
  final int currentStock;
  final int minStock;
  final bool showLabel;

  const StockStatusChip({
    super.key,
    required this.currentStock,
    required this.minStock,
    this.showLabel = true,
  });

  StockStatus get status {
    if (currentStock <= 0) return StockStatus.critical;
    if (currentStock <= minStock) return StockStatus.low;
    return StockStatus.ok;
  }

  Color get backgroundColor {
    switch (status) {
      case StockStatus.ok:
        return AppColors.successLight;
      case StockStatus.low:
        return AppColors.warningLight;
      case StockStatus.critical:
        return AppColors.errorLight;
    }
  }

  Color get textColor {
    switch (status) {
      case StockStatus.ok:
        return AppColors.success;
      case StockStatus.low:
        return AppColors.warning;
      case StockStatus.critical:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (status) {
      case StockStatus.ok:
        return Icons.check_circle_outline;
      case StockStatus.low:
        return Icons.warning_amber_rounded;
      case StockStatus.critical:
        return Icons.error_outline;
    }
  }

  String get label {
    switch (status) {
      case StockStatus.ok:
        return 'En stock';
      case StockStatus.low:
        return 'Stock bajo';
      case StockStatus.critical:
        return 'Agotado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelBold.copyWith(color: textColor),
            ),
          ],
          const SizedBox(width: 6),
          Text(
            '$currentStock',
            style: AppTextStyles.labelBold.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
