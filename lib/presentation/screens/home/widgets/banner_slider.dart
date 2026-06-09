import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F7133), Color(0xFF16A34A)], // Tailwind Emerald-700 ke Green-600
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F7133).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, bottom: -15,
            child: Icon(Icons.wb_sunny_rounded, size: 90, color: Colors.white.withOpacity(0.12))
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFF7A00), borderRadius: BorderRadius.circular(8)),
                child: Text('✨ PROMO BULAN INI', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
              ),
              const SizedBox(height: 12),
              Text('Diskon 30% Tiket\nMasuk Wisata Tasikmalaya',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3, letterSpacing: -0.3)),
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text('Klaim Voucher →', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F7133))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}