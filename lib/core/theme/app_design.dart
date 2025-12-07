import 'dart:ui';
import 'package:flutter/material.dart';

/// Design System estilo Apple - Monocromático con LiquidGlass
/// Colores en escala de grises, elegante y minimalista
abstract class AppDesign {
  // ==================== ESPACIADOS ====================
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  static const double screenPadding = 20;
  static const double navBarSpace = 110;

  // ==================== RADIOS ====================
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 20;
  static const double radiusXL = 28;
  static const double radiusPill = 100;

  // ==================== COLORES - ESCALA DE GRISES ====================
  // Fondos
  static const Color background = Color(0xFFF5F5F7);      // Gris muy claro Apple
  static const Color backgroundDark = Color(0xFF1C1C1E);  // Negro suave Apple
  static const Color surface = Colors.white;
  static const Color surfaceGlass = Color(0xE6FFFFFF);    // Blanco con 90% opacidad

  // Escala de grises (de más oscuro a más claro)
  static const Color gray900 = Color(0xFF1C1C1E);  // Casi negro
  static const Color gray800 = Color(0xFF2C2C2E);
  static const Color gray700 = Color(0xFF3A3A3C);
  static const Color gray600 = Color(0xFF48484A);
  static const Color gray500 = Color(0xFF636366);
  static const Color gray400 = Color(0xFF8E8E93);  // Gris medio Apple
  static const Color gray300 = Color(0xFFAEAEB2);
  static const Color gray200 = Color(0xFFD1D1D6);
  static const Color gray100 = Color(0xFFE5E5EA);
  static const Color gray50 = Color(0xFFF2F2F7);

  // Texto (escala de grises)
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;
  static const Color textTertiary = gray400;

  // Acentos (solo para estados importantes)
  static const Color accentSuccess = Color(0xFF34C759);  // Verde Apple para stock OK
  static const Color accentWarning = Color(0xFFFF9500);  // Naranja Apple para alertas
  static const Color accentError = Color(0xFFFF3B30);    // Rojo Apple para eliminar

  // ==================== SOMBRAS ====================
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: gray900.withAlpha(8),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: gray900.withAlpha(12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: gray900.withAlpha(15),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  // ==================== LIQUID GLASS ====================
  static ImageFilter get glassBlur => ImageFilter.blur(sigmaX: 20, sigmaY: 20);
  
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: surfaceGlass,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(
      color: Colors.white.withAlpha(50),
      width: 1,
    ),
    boxShadow: shadowMedium,
  );

  // ==================== DECORACIONES ====================
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowSmall,
  );

  static BoxDecoration get cardDecorationElevated => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowMedium,
  );

  // ==================== TIPOGRAFÍA ====================
  static const TextStyle headline = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // Precio ahora en gris oscuro para mantener monocromático
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: gray900,
    letterSpacing: -0.3,
  );
}

/// Widget LiquidGlass reutilizable
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const LiquidGlass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppDesign.radiusLarge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: AppDesign.glassBlur,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(AppDesign.space16),
              decoration: BoxDecoration(
                color: AppDesign.surfaceGlass,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withAlpha(80),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
