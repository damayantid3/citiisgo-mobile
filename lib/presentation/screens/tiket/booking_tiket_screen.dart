import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository_api.dart';
import '../../../providers/notifikasi_provider.dart';
import '../../../providers/booking_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class BookingTiketScreen extends StatefulWidget {
  final int wisataId;
  final int hargaTiket; // ✅ Dari API

  const BookingTiketScreen({
    super.key,
    required this.wisataId,
    this.hargaTiket = 25000,
  });

  @override
  State<BookingTiketScreen> createState() => _BookingTiketScreenState();
}

class _BookingTiketScreenState extends State<BookingTiketScreen> {
  final _bookingRepo = BookingRepositoryApi();
  int _jumlahTiket  = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;

  int get _hargaTiket => widget.hargaTiket;
  int get _totalHarga => _jumlahTiket * _hargaTiket;

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _prosesBooking() async {
    setState(() => _loading = true);

    try {
      // ✅ FIX UTAMA: field yang dikirim SESUAI dengan yang diharapkan API
      // API ReservasiController.store() expects:
      //   wisata_id, tanggal_kunjungan, jumlah_tiket, total_harga
      final r = await _bookingRepo.createBookingTiket({
        'wisata_id'         : widget.wisataId,       // ✅ wajib
        'tanggal_kunjungan' : _fmtDate(_selectedDate), // ✅ wajib
        'jumlah_tiket'      : _jumlahTiket,           // ✅ FIX: bukan jumlah_orang
        'total_harga'       : _totalHarga,            // ✅ tambahan
      });

      if (!mounted) return;
      setState(() => _loading = false);

      if (r['success'] == true) {
        final bookingId  = r['booking_id']?.toString() ??
            r['data']?['id']?.toString() ??
            'TKT-${DateTime.now().millisecondsSinceEpoch}';
        final paymentUrl = r['payment_url']?.toString() ?? '';

        // ✅ Notifikasi lokal
        context.read<NotifikasiProvider>().tambahNotifikasi(
          judul: 'Tiket Berhasil Dipesan! 🎉',
          pesan: '$_jumlahTiket tiket senilai '
              '${CurrencyFormatter.format(_totalHarga)} berhasil dibuat. '
              'Bayar dalam 1 jam agar tiket tidak hangus.',
          tipe: 'sukses',
        );

        // ✅ Refresh riwayat agar langsung muncul di tab "Belum Bayar"
        context.read<BookingProvider>().refresh();

        // ✅ Navigasi ke pembayaran dengan countdown 1 jam
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PembayaranScreen(
              paymentUrl  : paymentUrl,
              kodeBooking : bookingId,
              totalHarga  : _totalHarga,
              layanan     : 'Tiket Masuk Wisata Citiis',
              // ✅ Kirim expired_at = 1 jam dari sekarang ke PembayaranScreen
              expiredAt   : DateTime.now().add(const Duration(hours: 1)),
            ),
          ),
        );
      } else {
        _showError(r['message'] ?? 'Gagal memproses tiket.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Koneksi gagal: Pastikan API berjalan di port 8001.\n$e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildTanggalPicker(),
                  const SizedBox(height: 16),
                  _buildJumlahTiket(),
                  const SizedBox(height: 16),
                  _buildSummary(),
                  const SizedBox(height: 16),
                  _buildWarningTimer(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Tiket Masuk',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: -0.3,
                    )),
                Text('Pesan tiket masuk wisata alam lebih praktis',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70, fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ]),
      );

  Widget _buildInfoCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🎟️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kawasan Wisata Citiis Galunggung',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 14,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text('Tiket berlaku 1 orang / 1 kali masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(_hargaTiket)} / orang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ]),
      );

  Widget _buildTanggalPicker() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal Kunjungan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    )),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day} ${_bulan(_selectedDate.month)} '
                  '${_selectedDate.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _pilihTanggal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: Text('Ubah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                  )),
            ),
          ],
        ),
      );

  Widget _buildJumlahTiket() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah Tiket',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text('${CurrencyFormatter.format(_hargaTiket)} / orang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            Row(children: [
              _counterBtn(Icons.remove_rounded, _jumlahTiket > 1,
                  () => setState(() => _jumlahTiket--)),
              Container(
                width: 44, alignment: Alignment.center,
                child: Text('$_jumlahTiket',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    )),
              ),
              _counterBtn(Icons.add_rounded, _jumlahTiket < 50,
                  () => setState(() => _jumlahTiket++)),
            ]),
          ],
        ),
      );

  Widget _counterBtn(IconData ico, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primaryGreen : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ico,
              color: enabled ? Colors.white : AppColors.textMuted, size: 16),
        ),
      );

  Widget _buildSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 14,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 12),
            _sumRow('Harga Tiket', CurrencyFormatter.format(_hargaTiket)),
            _sumRow('Jumlah', '$_jumlahTiket Orang'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 14,
                      color: AppColors.textPrimary,
                    )),
                Text(CurrencyFormatter.format(_totalHarga),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 16,
                      color: AppColors.primaryGreen,
                    )),
              ],
            ),
          ],
        ),
      );

  // ✅ Peringatan timer 1 jam
  Widget _buildWarningTimer() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFE0B2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⏳', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batas Waktu Pembayaran: 1 Jam',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Setelah berhasil memesan, kamu wajib menyelesaikan pembayaran '
                    'dalam 1 jam. Jika melewati batas waktu, pesanan otomatis hangus '
                    'dan kuota tiket kembali tersedia.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5, color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w500, height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 20, offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Biaya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
              Text(CurrencyFormatter.format(_totalHarga),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  )),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 175, height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _prosesBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white,
                      ),
                    )
                  : Text('Beli Tiket Sekarang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
            ),
          ),
        ]),
      );

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
            Text(v,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      );

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _bulan(int m) => [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ][m];
}