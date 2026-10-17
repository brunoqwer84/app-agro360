import 'package:flutter/material.dart';

/// Paleta de cores moderna do Agro360
class AppColors {
  // Verde principal - Esmeralda moderna e profunda
  static const Color primary = Color(0xFF1E6F3E);
  static const Color primaryLight = Color(0xFF2E9354);
  static const Color primaryDark = Color(0xFF124B2B);
  static const Color primaryContainer = Color(0xFFE2F3E6);

  // Verde accent para gradientes
  static const Color accent = Color(0xFF34A86A);
  static const Color accentDark = Color(0xFF1E6F3E);

  // Neutros - Fundo suave e relaxante para o dia a dia no campo
  static const Color background = Color(0xFFF7FAF7);
  static const Color surface = Color(0xFFEEF4EF);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF131B15);
  static const Color textSecondary = Color(0xFF4E5E53);
  // Contraste >= 4.5:1 sobre branco (WCAG AA) para textos de apoio
  static const Color textHint = Color(0xFF7D8F82);
  static const Color divider = Color(0xFFE1E8E2);

  // Erro/sucesso/alerta
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFF87171);
  static const Color success = Color(0xFF1E824C);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);

  // Cores de categoria (cards de resumo e ações rápidas) - paleta própria vibrante
  static const Color categoryTeal = Color(0xFF0D9488);
  static const Color categoryBrown = Color(0xFF92400E);
  static const Color categoryBlue = Color(0xFF0284C7);
  static const Color categoryAmber = Color(0xFFD97706);
  static const Color categoryOrange = Color(0xFFEA580C);
  static const Color categoryRed = Color(0xFFE11D48);
  static const Color categoryPurple = Color(0xFF7C3AED);

  // Sombras suaves e difusas
  static const Color shadow = Color(0x0D000000);
  static const Color shadowLight = Color(0x06000000);
  static const Color shadowMedium = Color(0x18000000);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, accent],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F9F5), Colors.white],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F361F), Color(0xFF1E6F3E)],
  );
}
