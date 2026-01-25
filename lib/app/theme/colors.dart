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

  // Backgrounds
  static const Color darkBackground = Color(0xFF0F1014); // Deep Blue-Black
  static const Color darkSurface = Color(0xFF1D1F26);
  static const Color darkSurfaceVariant = Color(0xFF282A36);
  
  static const Color background = Color(0xFFF8F9FA); // Clean Light Grey
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // Status
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1A1A1A); // Dark text for light mode
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  // Glassmorphism System
  static const Color glassBorder = Colors.white24;
  static const Color glassBorderLight = Colors.black12;
  
  static const Color glassBackground = Color(0x1FFFFFFF); // 12% White (Dark Mode)
  static const Color glassBackgroundLight = Color(0x66FFFFFF); // 40% White (Light Mode)
  
  static const Color glassBackgroundStrong = Color(0x33FFFFFF); // 20% White
  static const Color glassBackgroundStrongLight = Color(0x99FFFFFF); // 60% White
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00CEC9), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFDA085), Color(0xFFF6D365)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0xCC1D1F26), Color(0x991D1F26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // UI Elements
  static const Color divider = Color(0xFF2D3436);
}
