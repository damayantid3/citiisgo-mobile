import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/wisata_model.dart';

class WisataCard extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback? onTap;

  const WisataCard({super.key, required this.wisata, this.onTap});

  Color get _gradientStart {
    switch (wisata.kategori) {
      // ignore: constant_pattern_never_matches_value_type
      case 'Pantai': return const Color(0xFF0D47A1);
      // ignore: constant_pattern_never_matches_value_type
      case 'Gunung': return const Color(0xFFE65100);
      default: return AppColors.darkGreen;
    }
  }

  Color get _gradientEnd {
    switch (wisata.kategori) {
      // ignore: constant_pattern_never_matches_value_type
      case 'Pantai': return const Color(0xFF1565C0);
      // ignore: constant_pattern_never_matches_value_type
      case 'Gunung': return AppColors.primaryOrange;
      default: return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_gradientStart, _gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Center(child: Text(wisata.emoji ?? '', style: const TextStyle(fontSize: 48))),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Tag
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(5)),
                    child: Text(wisata.tag ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wisata.nama, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Expanded(child: Text(wisata.lokasi ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text('⭐', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 2),
                        Text('${wisata.rating} (${wisata.jumlahUlasan})', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textSecondary)),
                      ]),
                      Text(CurrencyFormatter.formatShort(wisata.hargaTiket),
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}