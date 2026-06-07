import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static TextStyle get bodyBold => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted,
  );
  static TextStyle get price => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryGreen,
  );
  static TextStyle get priceSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen,
  );
  static TextStyle get label => GoogleFonts.plusJakartaSans(
    fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
  );
  static TextStyle get white => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white,
  );
}