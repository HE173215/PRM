import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Vibrant Neo-Minimalism (Carbon Pitch Black & Electric Accents)
  static const Color background = Color(0xFF09090B); // Pitch Zinc Carbon
  static const Color surface = Color(0xFF121215); // Matte Carbon Surface
  static const Color surfaceLight = Color(
    0xFF1C1C21,
  ); // Elevated Interactive Surface
  static const Color surfaceBorder = Color(
    0xFF27272A,
  ); // Crisp Minimalist Hairline

  // High-Contrast Vibrant Accents
  static const Color primary = Color(0xFFFF5500); // Electric Hyper Orange
  static const Color primaryLight = Color(0xFFFF7733); // Warm Neon Orange
  static const Color primaryDark = Color(0xFFCC4400); // Deep Racing Orange

  static const Color secondary = Color(0xFF00F0FF); // Cyber Neon Cyan
  static const Color emerald = Color(0xFF00E676); // Neon Matrix Green
  static const Color amber = Color(0xFFFFB800); // Signal Amber
  static const Color rose = Color(0xFFFF2E54); // Laser Crimson

  // Neutral Typography & Dividers
  static const Color textPrimary = Color(0xFFFAFAFA); // PureStark White
  static const Color textSecondary = Color(0xFFA1A1AA); // Neutral Zinc Gray
  static const Color textMuted = Color(0xFF71717A); // Technical Dim Gray
  static const Color divider = Color(0xFF1F1F23);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5500), Color(0xFFFF8800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF0088FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF18181C), Color(0xFF101013)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGoldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF7700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xCC09090B), Color(0xFF09090B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
