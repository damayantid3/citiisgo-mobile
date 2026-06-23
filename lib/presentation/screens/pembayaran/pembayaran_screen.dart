import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/notifikasi_provider.dart';
import '../../../providers/booking_provider.dart';

class PembayaranScreen extends StatefulWidget {
  final String paymentUrl;
  final String kodeBooking;
  final int totalHarga;
  final String layanan;
  final DateTime? expiredAt; // ✅ Terima expired_at dari booking

  const PembayaranScreen({
    super.key,
    required this.paymentUrl,
    required this.kodeBooking,
    required this.totalHarga,
    required this.layanan,
    this.expiredAt,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  int _selectedMethodIndex = -1;
  bool _isSimulating = false;
  bool _isExpired = false;

  // ✅ Countdown timer
  Timer? _timer;
  Duration _remaining = const Duration(hours: 1);

  static const _green  = Color(0xFF0F7133);
  static const _orange = Color(0xFFFF7A00);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ✅ Hitung sisa waktu dari expired_at atau fallback 1 jam
  void _startCountdown() {
    final deadline = widget.expiredAt ?? DateTime.now().add(const Duration(hours: 1));
    _updateRemaining(deadline);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining(deadline);
    });
  }

  void _updateRemaining(DateTime deadline) {
    final now  = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      setState(() {
        _remaining = Duration.zero;
        _isExpired = true;
      });
      _timer?.cancel();
      return;
    }
    setState(() => _remaining = diff);
  }

  String get _timerDisplay {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get _timerColor {
    if (_remaining.inMinutes < 5)  return Colors.redAccent;
    if (_remaining.inMinutes < 15) return _orange;
    return _green;
  }

  Future<void> _prosesSimulasiBayar() async {
    if (_isExpired) {
      _showSnack('Waktu pembayaran sudah habis. Silakan pesan ulang.', true);
      return;
    }

    if (_selectedMethodIndex == -1) {
      _showSnack('Silakan pilih metode pembayaran terlebih dahulu!', false);
      return;
    }

    setState(() => _isSimulating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _timer?.cancel();

    context.read<NotifikasiProvider>().tambahNotifikasi(
      judul: 'Pembayaran Sukses! 💳',
      pesan : 'Pembayaran ${widget.layanan} (${widget.kodeBooking}) '
          'senilai ${CurrencyFormatter.format(widget.totalHarga)} dinyatakan LUNAS.',
      tipe: 'sukses',
    );

    // ✅ Refresh riwayat dari API
    context.read<BookingProvider>().refresh();

    setState(() => _isSimulating = false);
    if (!mounted) return;

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle_rounded,
                    color: _green, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text('Pembayaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                )),
            const SizedBox(height: 8),
            Text(widget.kodeBooking,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: _green, letterSpacing: 0.5,
                )),
            const SizedBox(height: 6),
            Text(
              'Reservasi telah dikonfirmasi. Cek Tiket Aktif untuk e-ticket kamu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: const Color(0xFF64748B), height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text('Kembali ke Beranda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? Colors.redAccent : _orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Gerbang Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Countdown Timer Card
            _buildCountdownCard(),
            const SizedBox(height: 16),

            // Total Tagihan
            _buildTotalCard(),
            const SizedBox(height: 20),

            Text('Pilih Metode Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                )),
            const SizedBox(height: 12),

            // Transfer VA
            _buildMethodCard(
              index: 0,
              title: 'Transfer Virtual Account',
              desc: 'BCA, Mandiri, BNI, BRI',
              icon: Icons.account_balance_rounded,
              child: _buildVaContent(),
            ),

            // QRIS
            _buildMethodCard(
              index: 1,
              title: 'E-Wallet & Scan QRIS',
              desc: 'GoPay, OVO, DANA, LinkAja',
              icon: Icons.qr_code_scanner_rounded,
              child: _buildQrisContent(),
            ),

            const SizedBox(height: 24),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (_isSimulating || _isExpired) ? null : _prosesSimulasiBayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isExpired
                      ? Colors.grey
                      : (_selectedMethodIndex == -1
                          ? const Color(0xFFE2E8F0)
                          : _orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSimulating
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isExpired
                            ? '⏰ Waktu Habis — Pesan Ulang'
                            : 'Konfirmasi & Selesaikan Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text('🔒 Pembayaran diamankan oleh Midtrans',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Countdown Timer Card
  Widget _buildCountdownCard() => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isExpired
              ? const Color(0xFFFFEBEE)
              : (_remaining.inMinutes < 5
                  ? const Color(0xFFFFEBEE)
                  : (_remaining.inMinutes < 15
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFE8F5E9))),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _timerColor.withOpacity(0.3),
          ),
        ),
        child: Row(children: [
          Icon(
            _isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
            color: _timerColor, size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpired
                      ? 'Waktu Pembayaran Habis!'
                      : 'Sisa Waktu Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: _timerColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isExpired ? 'Pesanan otomatis dibatalkan' : _timerDisplay,
                  style: GoogleFonts.spaceMono(
                    fontSize: _isExpired ? 14 : 22,
                    fontWeight: FontWeight.w800,
                    color: _timerColor,
                  ),
                ),
              ],
            ),
          ),
          if (!_isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _timerColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _remaining.inMinutes < 5 ? '⚠️ Segera' : 'Aktif',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: _timerColor,
                ),
              ),
            ),
        ]),
      );

  Widget _buildTotalCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(children: [
          Text('TOTAL TAGIHAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700, letterSpacing: 1,
              )),
          const SizedBox(height: 6),
          Text(CurrencyFormatter.format(widget.totalHarga),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28, fontWeight: FontWeight.w900,
                color: _green,
              )),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _invoiceRow('Kode Booking', widget.kodeBooking),
          _invoiceRow('Layanan', widget.layanan),
          _invoiceRow('Vendor', 'Midtrans Payment Gateway'),
        ]),
      );

  Widget _buildVaContent() => Column(
        children: [
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          _vaRow('BCA Virtual Account',
              '8830${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
          _vaRow('Mandiri Virtual Account',
              '9001${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
          _vaRow('BNI Virtual Account',
              '4600${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
          _vaRow('BRI BRIVA',
              '1280${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
          const SizedBox(height: 6),
          Text('* Salin nomor VA dan transfer lewat m-Banking / ATM.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5, color: const Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              )),
        ],
      );

  Widget _buildQrisContent() => Column(
        children: [
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 120),
            ),
          ),
          const SizedBox(height: 10),
          Text('Scan QR Code di atas\nmenggunakan e-wallet pilihanmu',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: const Color(0xFF64748B), height: 1.5,
              )),
        ],
      );

  Widget _buildMethodCard({
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    required Widget child,
  }) {
    final isOpen = _selectedMethodIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethodIndex = isOpen ? -1 : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? _green : const Color(0xFFE2E8F0),
            width: isOpen ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon,
                  color: isOpen ? _green : _orange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5, fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        )),
                    if (!isOpen)
                      Text(desc,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          )),
                  ],
                ),
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF94A3B8),
              ),
            ]),
            if (isOpen) child,
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
                  fontSize: 12, color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                )),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  )),
            ),
          ],
        ),
      );

  Widget _vaRow(String bank, String noVa) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(bank,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                )),
            Row(children: [
              Text(noVa,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12, fontWeight: FontWeight.w800,
                    color: _green, letterSpacing: 0.5,
                  )),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: noVa));
                  _showSnack('Nomor VA disalin!', false);
                },
                child: const Icon(Icons.copy_rounded,
                    size: 14, color: _green),
              ),
            ]),
          ],
        ),
      );
}