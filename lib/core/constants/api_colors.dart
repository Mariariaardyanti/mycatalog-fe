import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary      = Color(0xFFC9A84C); // Gold utama
  static const Color primaryDark  = Color(0xFF9A7832); // Gold gelap — pressed / shadow
  static const Color primaryLight = Color(0xFFF5E9C8); // Gold muda  — border / divider
  static const Color primaryFill  = Color(0xFFFDF6E3); // Gold pucat — fill input / chip

  static const Color background   = Color(0xFFFAF7F2); // Scaffold (krem hangat)
  static const Color surface      = Color(0xFFFFFFFF); // Card / AppBar / BottomSheet
  static const Color surfaceAlt   = Color(0xFFF7F3EC); // Surface alternatif

  static const Color textPrimary  = Color(0xFF2C1F0E); // Heading & body utama
  static const Color textSecondary= Color(0xFF8C7A5E); // Caption / label / placeholder
  static const Color textOnGold   = Color(0xFFFFFFFF); // Teks di atas warna gold

  static const Color error        = Color(0xFFD32F2F);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color success      = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning      = Color(0xFFF57C00);
  static const Color info         = Color(0xFF1976D2);

  static Color get shadowGold     => primary.withOpacity(0.28);
  static Color get overlayPressed => primaryDark.withOpacity(0.12);
  static Color get divider        => primaryLight;
  static Color get shimmerBase    => primaryFill;
  static Color get shimmerHighlight => surface;
}