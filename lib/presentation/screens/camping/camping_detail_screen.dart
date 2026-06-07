import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/models/paket_camping_model.dart';
import 'booking_camping_screen.dart';

class CampingDetailScreen extends StatelessWidget {
  final WisataModel wisata;
  const CampingDetailScreen({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    final pakets = PaketCampingModel.dummyList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Pilih Paket Camping', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: pakets.length,
        itemBuilder: (_, i) {
          final p = pakets[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCampingScreen(wisataId: wisata.id))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(p.nama, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(CurrencyFormatter.format(p.hargaPerMalam) + '/malam',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                  ]),
                  const SizedBox(height: 6),
                  Text(p.deskripsi ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Maks. ${p.maxTamu} tamu', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}