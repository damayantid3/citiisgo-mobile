import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KategoriChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const KategoriChip({super.key, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F7133) : Colors.white,
          borderRadius: BorderRadius.circular(14), // Sudut tumpul estetik
          boxShadow: [
            if (!isActive) BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: isActive ? const Color(0xFF0F7133) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, 
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}