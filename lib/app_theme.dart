import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF4F46E5); // indigo 600
  static const Color _primaryLight = Color(0xFF6366F1);
  static const Color _accent = Color(0xFF9333EA); // purple 600
  static const Color _darkSurface = Color(0xFF1C1B1F);

  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: _primary,
    secondary: _accent,
  );

  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: _primaryLight,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _primaryLight,
    secondary: _accent,
    surface: _darkSurface,
  );

  static ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get lightTheme => _buildTheme(lightColorScheme);
  static ThemeData get darkTheme => _buildTheme(darkColorScheme);
}
