import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernTheme {
  // Primary Gradient Colors
  static const Color primaryGradientStart = Color(0xFF6B46C1);
  static const Color primaryGradientEnd = Color(0xFF4C7EF3);
  
  // Secondary Gradient Colors
  static const Color secondaryGradientStart = Color(0xFFFF6B9D);
  static const Color secondaryGradientEnd = Color(0xFFFECA57);
  
  // Success Gradient
  static const Color successGradientStart = Color(0xFF00C9A7);
  static const Color successGradientEnd = Color(0xFF00E4CC);
  
  // Error Gradient
  static const Color errorGradientStart = Color(0xFFFF4757);
  static const Color errorGradientEnd = Color(0xFFFF6B9D);
  
  // Neutral Colors
  static const Color backgroundPrimary = Color(0xFF0A0E21);
  static const Color backgroundSecondary = Color(0xFF1A1F36);
  static const Color cardBackground = Color(0xFF1E2336);
  static const Color surfaceColor = Color(0xFF2A2F45);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textTertiary = Color(0xFF7B8192);
  
  // Glass Effect Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryGradientStart, secondaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [successGradientStart, successGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorGradientStart, errorGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundPrimary, backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: primaryGradientStart.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 5),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryGradientStart.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: Color(0xFF48BFE3).withOpacity(0.5),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];
}
