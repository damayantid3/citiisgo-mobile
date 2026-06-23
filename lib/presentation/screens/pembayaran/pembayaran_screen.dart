import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/notifikasi_provider.dart';
import '../../../providers/booking_provider.dart'; // ✅ Refresh riwayat setelah bayar

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
  int _selectedMethodIndex = -1; // -1 = semua tertutup

  Future<void> _prosesSimulasiBayar() async {
    if (_selectedMethodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan pilih salah satu metode pembayaran!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primaryOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSimulating = true);

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // ✅ Notifikasi sukses bayar
    context.read<NotifikasiProvider>().tambahNotifikasi(
      judul: 'Pembayaran Sukses! 💳',
      pesan:
          'Pembayaran ${widget.layanan} (${widget.kodeBooking}) sebesar ${CurrencyFormatter.format(widget.totalHarga)} dinyatakan LUNAS.',
      tipe: 'sukses',
    );

    // ✅ Refresh riwayat dari API agar status langsung terupdate
    context.read<BookingProvider>().refresh();

    setState(() => _isSimulating = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Berhasil!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.kodeBooking,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reservasi telah dikonfirmasi. Cek riwayat tiket untuk e-ticket kamu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.textSecondary, height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerbang Pembayaran',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kartu Total Tagihan ──
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
                    'TOTAL TAGIHAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700, letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(widget.totalHarga),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const Divider(height: 28, color: AppColors.borderColor),
                  _invoiceRow('Kode Booking', widget.kodeBooking),
                  _invoiceRow('Layanan', widget.layanan),
                  _invoiceRow('Vendor', 'Midtrans Payment Gateway'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Pilih Metode Pembayaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // ── Opsi 1: Transfer VA ──
            _buildMethodCard(
              index: 0,
              title: 'Transfer Virtual Account',
              desc: 'BCA, Mandiri, BNI, BRI',
              icon: Icons.account_balance_rounded,
              child: Column(
                children: [
                  const Divider(color: AppColors.borderColor, height: 20),
                  _buildBankVaRow('BCA Virtual Account',
                      '8830${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
                  _buildBankVaRow('Mandiri Virtual Account',
                      '9001${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
                  _buildBankVaRow('BNI Virtual Account',
                      '4600${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
                  _buildBankVaRow('BRI BRIVA',
                      '1280${widget.kodeBooking.replaceAll(RegExp(r'\D'), '').padLeft(8, '0')}'),
                  const SizedBox(height: 6),
                  Text(
                    '* Salin nomor VA dan transfer lewat m-Banking / ATM.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5, color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // ── Opsi 2: QRIS ──
            _buildMethodCard(
              index: 1,
              title: 'E-Wallet & Scan QRIS',
              desc: 'GoPay, OVO, DANA, LinkAja',
              icon: Icons.qr_code_scanner_rounded,
              child: Column(
                children: [
                  const Divider(color: AppColors.borderColor, height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.borderColor, width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 120,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scan QR Code di atas\nmenggunakan e-wallet pilihanmu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol Konfirmasi ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSimulating ? null : _prosesSimulasiBayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethodIndex == -1
                      ? AppColors.borderColor
                      : AppColors.primaryOrange,
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
                        'Konfirmasi & Selesaikan Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '🔒 Pembayaran diamankan oleh Midtrans',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? AppColors.primaryGreen : AppColors.borderColor,
            width: isOpen ? 2 : 1,
          ),
          boxShadow: isOpen
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.04),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: isOpen
                        ? AppColors.primaryGreen
                        : AppColors.primaryOrange,
                    size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          )),
                      if (!isOpen)
                        Text(desc,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5, color: AppColors.textSecondary,
                            )),
                    ],
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
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
                  fontSize: 12, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
            ),
          ],
        ),
      );

  Widget _buildBankVaRow(String bank, String noVa) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(bank,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                )),
            Row(
              children: [
                Text(noVa,
                    style: GoogleFonts.spaceMono(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen, letterSpacing: 0.5,
                    )),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: noVa));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nomor VA disalin!',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            )),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy_rounded,
                      size: 14, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ],
        ),
      );
}