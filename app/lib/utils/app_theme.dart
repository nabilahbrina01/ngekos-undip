import 'package:flutter/material.dart';

/// Warna utama aplikasi NgekosUndip (nuansa biru navy + emas).
class AppColors {
  static const Color navy = Color(0xFF0B2A4A);
  static const Color navyLight = Color(0xFF1B4F8C);
  static const Color gold = Color(0xFFF5B301);
  static const Color goldSoft = Color(0xFFFFF4D6);
  static const Color background = Color(0xFFF4F6FA);
  static const Color border = Color(0xFFE3E7EF);
  static const Color textMuted = Color(0xFF6B7280);

  /// Gradasi untuk header (Beranda, Login, Profil).
  static const LinearGradient headerGradient = LinearGradient(
    colors: [navy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bayangan lembut untuk kartu.
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: navy.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Tema global, dipakai di main.dart.
class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: Colors.white,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.goldSoft,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}