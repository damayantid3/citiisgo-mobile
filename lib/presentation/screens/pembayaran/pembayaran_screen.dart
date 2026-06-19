import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../providers/notifikasi_provider.dart';

class PembayaranScreen extends StatefulWidget {
  final String paymentUrl;
  final String kodeBooking;
  final int totalHarga;
  final String layanan;
  final bool isFromHistory;

  const PembayaranScreen({
    super.key,
    required this.paymentUrl,
    required this.kodeBooking,
    required this.totalHarga,
    required this.layanan,
    this.isFromHistory = false,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  final _bookingRepo = BookingRepository();
  bool _isCheckingStatus = false;
  bool _isOpeningPayment = false;

  Future<void> _bukaHalamanPembayaran() async {
    if (widget.paymentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link pembayaran tidak tersedia. Hubungi admin.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isOpeningPayment = true);

    final uri = Uri.parse(widget.paymentUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!mounted) return;
    setState(() => _isOpeningPayment = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka halaman pembayaran.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cekStatusPembayaran() async {
    setState(() => _isCheckingStatus = true);

    final res = await _bookingRepo.cekStatusPembayaran(widget.kodeBooking);

    if (!mounted) return;
    setState(() => _isCheckingStatus = false);

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal memeriksa status.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final status = res['status'] as String;

    if (status == 'Lunas') {
      context.read<NotifikasiProvider>().tambahNotifikasi(
            judul: 'Pembayaran Sukses! 💳',
            pesan:
                'Pembayaran tagihan untuk ${widget.layanan} (${widget.kodeBooking}) sebesar ${CurrencyFormatter.format(widget.totalHarga)} dinyatakan LUNAS.',
            tipe: 'sukses',
          );
      _showSuccessDialog();
    } else if (status == 'Dibatalkan') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservasi ini sudah dibatalkan.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Pembayaran belum terkonfirmasi. Selesaikan pembayaran lalu cek lagi beberapa saat.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Pembayaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Status reservasi otomatis terupdate di dalam sistem riwayat aplikasi dan lonceng notifikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (widget.isFromHistory) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                    widget.isFromHistory
                        ? 'Kembali ke Riwayat'
                        : 'Kembali ke Beranda',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Gerbang Transaksi',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU TOTAL TAGIHAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Text('TOTAL TAGIHAN BILL',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(CurrencyFormatter.format(widget.totalHarga),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen)),
                  const Divider(height: 30, color: AppColors.borderColor),
                  _invoiceRow('Kode Booking', widget.kodeBooking),
                  _invoiceRow('Detail Layanan', widget.layanan),
                  _invoiceRow('Faktur Vendor', 'Midtrans Payment Gateway'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PANDUAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text('Cara Menyelesaikan Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Tekan "Bayar Sekarang" untuk membuka halaman pembayaran Midtrans (Virtual Account, E-Wallet, QRIS, dll).\n'
                    '2. Selesaikan pembayaran sesuai metode yang dipilih.\n'
                    '3. Kembali ke aplikasi ini dan tekan "Cek Status Pembayaran".',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // TOMBOL BAYAR SEKARANG
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isOpeningPayment ? null : _bukaHalamanPembayaran,
                icon: _isOpeningPayment
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5))
                    : const Icon(Icons.payment_rounded,
                        color: AppColors.white, size: 18),
                label: Text('Bayar Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // TOMBOL CEK STATUS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isCheckingStatus ? null : _cekStatusPembayaran,
                icon: _isCheckingStatus
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen, strokeWidth: 2.5))
                    : const Icon(Icons.refresh_rounded,
                        color: AppColors.primaryGreen, size: 18),
                label: Text('Cek Status Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
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
            Text(k,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(v,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
}
