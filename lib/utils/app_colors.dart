import 'package:flutter/material.dart';

/// Paleta de cores moderna do Agro360
class AppColors {
  // Verde principal
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryContainer = Color(0xFFC8E6C9);

  // Verde accent para gradientes
  static const Color accent = Color(0xFF66BB6A);
  static const Color accentDark = Color(0xFF388E3C);

  // Neutros
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F7F5);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1A1D1A);
  static const Color textSecondary = Color(0xFF616661);
  static const Color textHint = Color(0xFF9CA39C);
  static const Color divider = Color(0xFFE0E5E0);

  // Erro/sucesso
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Sombras
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1F8E9), Colors.white],
  );
}