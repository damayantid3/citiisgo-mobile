import 'package:flutter/material.dart';

class AppColors {
  // Primary Green
  static const Color primaryGreen  = Color(0xFF1A6B2A);
  static const Color darkGreen     = Color(0xFF0D3D18);
  static const Color lightGreen    = Color(0xFFE8F5E9);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color mediumGreen   = Color(0xFF2E7D32);
  static const Color green100      = Color(0xFFC8E6C9);

  // Accent Orange
  static const Color primaryOrange = Color(0xFFF47A20);
  static const Color lightOrange   = Color(0xFFFFF3E0);
  static const Color darkOrange    = Color(0xFFE65100);
  static const Color infoColor     = Color(0xFF1565C0);
  static const Color purpleAccent  = Color(0xFF6A1B9A);
  static const LinearGradient heroGradient = LinearGradient(
    colors: [darkGreen, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = heroGradient;

  // Neutral
  static const Color white         = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFF0F4F8);
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A6475);
  static const Color textMuted     = Color(0xFF9BA3AF);
  static const Color borderColor   = Color(0xFFE2E8F0);

  // Status
  static const Color success       = Color(0xFF2E7D32);
  static const Color warning       = Color(0xFFF9A825);
  static const Color warningBg     = Color(0xFFFFF8E1);
  static const Color danger        = Color(0xFFD32F2F);
  static const Color dangerLight   = Color(0xFFFFEBEE);
  static const Color info          = Color(0xFF1565C0);
}