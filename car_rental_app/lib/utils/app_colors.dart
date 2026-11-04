import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Luxury Midnight & Deep Navy
  static const Color background = Color(0xFF0D131F); // Deep midnight obsidian
  static const Color surface = Color(0xFF161F30);    // Elevated dark card surface
  static const Color surfaceLight = Color(0xFF1F2B42); // Hover / Highlight surface
  static const Color surfaceBorder = Color(0xFF2A3854); // Subtle luxury borders

  // Accent Colors
  static const Color primary = Color(0xFF4F46E5);      // Electric Indigo
  static const Color primaryLight = Color(0xFF6366F1); // Lighter Indigo
  static const Color primaryDark = Color(0xFF3730A3);  // Deep Indigo
  
  static const Color secondary = Color(0xFF06B6D4);    // Cyan Blue Accent
  static const Color emerald = Color(0xFF10B981);      // Emerald Green (Success/Eco)
  static const Color amber = Color(0xFFF59E0B);        // Amber Gold (Rating/Warning)
  static const Color rose = Color(0xFFEF4444);         // Ruby Red (Error/Cancel)

  // Neutral Colors
  static const Color textPrimary = Color(0xFFF8FAFC);  // Crisp white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate gray
  static const Color textMuted = Color(0xFF64748B);    // Dim caption gray
  static const Color divider = Color(0xFF1E293B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGoldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xCC0D131F), Color(0xFF0D131F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
