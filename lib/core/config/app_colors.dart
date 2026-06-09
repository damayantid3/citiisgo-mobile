import 'package:flutter/material.dart';

class AppColors {
  // Brand Utama CitiisGo (Sesuai CitiisgoLogo.jpeg)
  static const Color primaryGreen  = Color(0xFF0F7133);
  static const Color darkGreen     = Color(0xFF064E3B);
  static const Color lightGreen    = Color(0xFFDCFCE7); // Tailwind green-100
  static const Color accentGreen   = Color(0xFF22C55E);
  static const Color mediumGreen   = Color(0xFF16A34A);
  static const Color green100      = Color(0xFFE2F0D9);

  // Aksen Warna Oranye Petualangan
  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color lightOrange   = Color(0xFFFFF3E0);
  static const Color darkOrange    = Color(0xFFEA580C);
  
  // Modul Warna Ungu Komponen Sewa Alat (Eksklusif)
  static const Color purplePrimary = Color(0xFF7C3AED);
  static const Color purpleDark    = Color(0xFF5B21B6);
  static const Color purpleLight   = Color(0xFFF3E8FF);

  // Gradien Premium
  static const LinearGradient heroGradient = LinearGradient(
    colors: [darkGreen, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient primaryGradient = heroGradient;

  // Palet Netral Lapang & Bersih (Tailwind Slate Style)
  static const Color white         = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFF8FAFC); // Slate-50 untuk kesan luas
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF0F172A); // Slate-900 (Mudah dibaca)
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textMuted     = Color(0xFF94A3B8); // Slate-400
  static const Color borderColor   = Color(0xFFE2E8F0); // Slate-200

  // Status Transaksi Terintegrasi API
  static const Color success       = Color(0xFF16A34A);
  static const Color warning       = Color(0xFFD97706);
  static const Color warningBg     = Color(0xFFFEF3C7);
  static const Color danger        = Color(0xFFEF4444);
  static const Color dangerLight   = Color(0xFFFEE2E2);
  static const Color info          = Color(0xFF2563EB);
}