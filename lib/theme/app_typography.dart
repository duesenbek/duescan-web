import 'package:flutter/material.dart';

/// Custom typography system for DueScan using Inter and SF Pro fonts
class AppTypography {
  // Font families
  static const String _interFont = 'Inter';
  static const String _sfProFont = 'SFPro';

  /// Primary typography using Inter for body text and UI elements
  static TextTheme get interTextTheme => const TextTheme(
    // Display styles - SF Pro for headlines
    displayLarge: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    
    // Headline styles - SF Pro for headings
    headlineLarge: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 32,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    
    // Title styles - SF Pro for titles
    titleLarge: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: _sfProFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    
    // Body styles - Inter for readability
    bodyLarge: TextStyle(
      fontFamily: _interFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _interFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: _interFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    
    // Label styles - Inter for labels and buttons
    labelLarge: TextStyle(
      fontFamily: _interFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: _interFont,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: _interFont,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  /// Specialized text styles for specific use cases
  static const TextStyle tokenSymbol = TextStyle(
    fontFamily: _sfProFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle tokenName = TextStyle(
    fontFamily: _sfProFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle tokenBalance = TextStyle(
    fontFamily: _interFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle tokenPrice = TextStyle(
    fontFamily: _interFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  );

  static const TextStyle sentimentBadge = TextStyle(
    fontFamily: _interFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _sfProFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _interFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _interFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  static const TextStyle errorMessage = TextStyle(
    fontFamily: _interFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle monospace = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// Access to base text theme styles
  static TextStyle get titleSmall => interTextTheme.titleSmall!;
  static TextStyle get bodyMedium => interTextTheme.bodyMedium!;
  static TextStyle get labelMedium => interTextTheme.labelMedium!;
  static TextStyle get headlineSmall => interTextTheme.headlineSmall!;
  static TextStyle get bodyLarge => interTextTheme.bodyLarge!;
  static TextStyle get bodySmall => interTextTheme.bodySmall!;
  static TextStyle get titleMedium => interTextTheme.titleMedium!;
  static TextStyle get labelSmall => interTextTheme.labelSmall!;

  /// Helper method to get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Helper method to get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Helper method to get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
