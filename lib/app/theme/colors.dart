import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6C63FF); // Modern Purple
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFFA29BFE);
  
  // Accents
  static const Color accent = Color(0xFF00CEC9); // Teal/Cyan
  static const Color accentLight = Color(0xFF55EFC4); // Lighter Teal for legacy support
  static const Color accentSecondary = Color(0xFFFD79A8); // Soft Pink

  // Backgrounds (Dark Mode Focus)
  static const Color darkBackground = Color(0xFF0F1014); // Deep Blue-Black
  static const Color darkSurface = Color(0xFF1D1F26);
  static const Color darkSurfaceVariant = Color(0xFF282A36);
  
  // Legacy / Light Mode Aliases (mapped to dark for consistency or proper light values)
  // For now, mapping to dark to force the premium dark look, or could add actual light colors.
  // Since we forced Dark Theme in app.dart, these might only be accessed by code checking 'isDark'.
  // We'll provide valid colors to prevent build errors.
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // Status
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);
  
  // UI Elements
  static const Color divider = Color(0xFF2D3436);
}
