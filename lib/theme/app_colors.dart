import 'package:flutter/material.dart';

abstract class AppColors {
  // --- Colores corporativos ---
  static const Color primary = Color(0xFFFF6B00);       // Naranja deportivo RS Sport
  static const Color primaryDark = Color(0xFFCC5500);    // Naranja oscuro (hover/pressed)
  static const Color primaryLight = Color(0xFFFF9A4D);   // Naranja claro (tint)

  // --- Neutros ---
  static const Color black = Color(0xFF0D0D0D);          // Negro principal
  static const Color white = Color(0xFFFFFFFF);          // Blanco puro
  static const Color grey = Color(0xFF9E9E9E);           // Gris medio
  static const Color greyLight = Color(0xFFF5F5F5);     // Gris claro (backgrounds)
  static const Color greyDark = Color(0xFF424242);       // Gris oscuro

  // --- Superficie ---
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundDark = Color(0xFF0D0D0D);

  // --- Semánticos ---
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);

  // --- Sombras (ARGB: 0xAARRGGBB) ---
  static const Color shadowLight = Color(0x0F000000);    // 6% negro
  static const Color shadowMedium = Color(0x14000000);   // 8% negro
  static const Color shadowDark = Color(0x1A000000);     // 10% negro
}
