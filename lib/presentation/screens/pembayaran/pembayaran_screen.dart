import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';

class PembayaranScreen extends StatefulWidget {
  final String paymentUrl;
  final String kodeBooking;
  final int totalHarga;
  final String layanan;

  const PembayaranScreen({
    super.key,
    required this.paymentUrl,
    required this.kodeBooking,
    required this.totalHarga,
    required this.layanan,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  bool _isSimulating = false;
  final _bookingRepo = BookingRepository();

  void _prosesSimulasiBayar() {
    setState(() => _isSimulating = true);
    
    Future.delayed(const Duration(seconds: 1), () {
      // PERBAIKAN UTAMA: Memastikan widget masih terpasang di layar (mencegah crash async gap)
      if (!mounted) return;
      
      // Mengubah status transaksi menjadi Lunas di memori lokal aplikasi
      _bookingRepo.updateStatusBayar(widget.kodeBooking);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
              const SizedBox(height: 16),
              Text(
                'Pembayaran Berhasil!', 
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
              ),
              const SizedBox(height: 8),
              Text(
                'Status reservasi otomatis terupdate di dalam sistem riwayat aplikasi.', 
                textAlign: TextAlign.center, 
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Menutup jendela Dialog pop-up
                    Navigator.of(context).popUntil((route) => route.isFirst); // Kembali ke struktur Beranda Utama
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali ke Beranda', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerbang Transaksi', 
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Text(
                    'TOTAL TAGIHAN BILL', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(widget.totalHarga), 
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)
                  ),
                  const Divider(height: 30, color: AppColors.borderColor),
                  _invoiceRow('Kode Booking', widget.kodeBooking),
                  _invoiceRow('Detail Layanan', widget.layanan),
                  _invoiceRow('Faktur Vendor', 'Midtrans Payment Gateway'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Petunjuk Sesi Pembayaran', 
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              'Transfer Virtual Account (VA)', 
              'Mendukung pembayaran penuh otomatis dari Bank BCA, Mandiri, BNI, BRI, atau Permata.'
            ),
            _buildInstructionCard(
              'E-Wallet & Scan QRIS', 
              'Buka aplikasi e-wallet pilihanmu (Gopay/OVO/Dana/LinkAja) lalu arahkan scanner kamera ke QR Code Midtrans Sandbox.'
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSimulating ? null : _prosesSimulasiBayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSimulating
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                    : Text('Simulasi Bayar Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildInstructionCard(String title, String desc) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.circular(14), 
          border: Border.all(color: AppColors.borderColor)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryOrange, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            )
          ],
        ),
      );
}