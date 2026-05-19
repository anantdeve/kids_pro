import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color orangePrimary = Color(0xFFFF7A59); // Used for "Hi, Nothing!" and card titles
  static const Color orangeLight = Color(0xFFFFE8E0);
  static const Color blueLight = Color(0xFFE0F4FF);
  static const Color softSky = Color(0xFFF0F9FF);
  static const Color pinkPrimary = Color(0xFFEF476F);
  
  // Gradients
  static const LinearGradient magicBookGradient = LinearGradient(
    colors: [
      Color(0xFFDB94FF), // Purple
      Color(0xFFFF9EF4), // Pink
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text colors
  static const Color textDark = Color(0xFF4A4A4A);
  static const Color textGray = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;

  // Background and UI elements
  static const Color background = Color(0xFFFDFDFD); // We'll use a gradient overlay in the UI
  static const Color cardBackground = Colors.white;
  
  // Legacy colors for other screens
  static const Color primaryYellow = Color(0xFFFFD166);
  static const Color primaryBlue = Color(0xFF118AB2);
  static const Color primaryPink = Color(0xFFEF476F);
  static const Color primaryGreen = Color(0xFF06D6A0);
  static const Color textPrimary = Color(0xFF073B4C);
  static const Color textSecondary = Color(0xFF4A4E69);
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowGlow = Color(0x1A000000);
}
