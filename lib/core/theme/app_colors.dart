import 'package:flutter/material.dart';

/// Paleta de colores de Papelería Moderna
/// Inspirada en artículos de papelería premium
abstract class AppColors {
  // Colores Primarios
  static const Color inkBlue = Color(0xFF1E3A5F);       // Azul Tinta
  static const Color inkBlueDark = Color(0xFF152A45);   // Azul Tinta oscuro
  static const Color inkBlueLight = Color(0xFF2E5A8F);  // Azul Tinta claro

  // Colores de Acento
  static const Color pencilOrange = Color(0xFFFF6B35);  // Naranja Lápiz
  static const Color pencilOrangeLight = Color(0xFFFF8F5A);

  // Neutros
  static const Color paperWhite = Color(0xFFF8F9FA);    // Blanco papel
  static const Color paperGrey = Color(0xFFF5F5F5);     // Gris papel
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Estados
  static const Color success = Color(0xFF10B981);       // Verde éxito
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);       // Amarillo advertencia
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);         // Rojo error
  static const Color errorLight = Color(0xFFFEE2E2);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [inkBlue, inkBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [pencilOrange, pencilOrangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Liquid Glass Effect Colors (usando Color.fromRGBO para evitar deprecated)
  static const Color liquidGlassBackground = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color liquidGlassBorder = Color.fromRGBO(255, 255, 255, 0.3);
  static const List<Color> liquidGlassHighlight = [
    Color.fromRGBO(255, 255, 255, 0.5),
    Color.fromRGBO(255, 255, 255, 0.0),
  ];
}
