import 'package:flutter/material.dart';

/// Tasarımdaki renkler (docs/tasarim/gorevakis.css ile aynı).
class AppColors {
  AppColors._();

  static const ink = Color(0xFF17211B); // ana metin, koyu yüzeyler
  static const paper = Color(0xFFEEF0EA); // ekran zemini
  static const muted = Color(0xFF56625A); // ikincil metin
  static const text2 = Color(0xFF2E3832); // uzun metin
  static const lime = Color(0xFFD3F26A); // vurgu, "Devam Ediyor"
  static const forest = Color(0xFF1F3A2C); // "Tamamlandı", koyu kart
  static const tray = Color(0xFFE0E4DA); // "Yapılacak"
  static const tomato = Color(0xFFB23A1E); // gecikme, uyarı
  static const tomatoLight = Color(0xFFFBE3DA);
  static const grey = Color(0xFF9AA59D);
  static const line = Color(0xFFE3E6DE);
  static const line2 = Color(0xFFD9DDD3);
  static const outline = Color(0xFFC9CFC4);
  static const handle = Color(0xFFD3D8CE);
  static const menuMuted = Color(0xFFAEB8B1);
  static const badge = Color(0xFFE2603F);
  static const sage = Color(0xFFB9C9BE);
  static const pine = Color(0xFF2E5E4E);
  static const online = Color(0xFF3E9B5F);
  static const scrim = Color(0x8C17211B);
  static const inputOnDark = Color(0x1AFFFFFF);
}

/// Yazı stilleri. Başlıklar Bricolage Grotesque, gövde Instrument Sans.
class AppText {
  AppText._();

  static const displayFamily = 'Bricolage Grotesque';
  static const bodyFamily = 'Instrument Sans';

  /// Başlık yazısı (Bricolage Grotesque).
  static TextStyle d(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
    double? spacing,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing ?? -size * 0.025,
    );
  }

  /// Gövde yazısı (Instrument Sans).
  static TextStyle b(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.forest,
    primary: AppColors.forest,
    onPrimary: Colors.white,
    secondary: AppColors.lime,
    onSecondary: AppColors.ink,
    surface: Colors.white,
    onSurface: AppColors.ink,
    error: AppColors.tomato,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppText.bodyFamily,
    scaffoldBackgroundColor: AppColors.paper,
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.ink,
      selectionColor: Color(0x80D3F26A),
      selectionHandleColor: AppColors.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.b(14, weight: FontWeight.w500, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: AppColors.line,
  );
}
