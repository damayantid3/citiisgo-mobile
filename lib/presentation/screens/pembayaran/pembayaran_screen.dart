import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../providers/notifikasi_provider.dart'; // Import Provider Notifikasi

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

  // State untuk mengontrol metode mana yang sedang diklik/dibuka (Accordion)
  int _selectedMethodIndex = -1; // -1 berarti semua tertutup, 0 = Transfer, 1 = E-Wallet

  void _prosesSimulasiBayar() {
    if (_selectedMethodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih salah satu metode pembayaran di bawah!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSimulating = true);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      // 1. Mengubah status transaksi menjadi Lunas di memori lokal repositori riwayat
      _bookingRepo.updateStatusBayar(widget.kodeBooking);
      
      // 2. Kirim update status sukses ke NotifikasiProvider secara realtime
      context.read<NotifikasiProvider>().tambahNotifikasi(
        judul: 'Pembayaran Sukses! 💳',
        pesan: 'Pembayaran tagihan untuk ${widget.layanan} (${widget.kodeBooking}) sebesar ${CurrencyFormatter.format(widget.totalHarga)} dinyatakan LUNAS.',
        tipe: 'sukses',
      );
      
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
                'Status reservasi otomatis terupdate di dalam sistem riwayat aplikasi dan lonceng notifikasi.', 
                textAlign: TextAlign.center, 
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); 
                    Navigator.of(context).popUntil((route) => route.isFirst); 
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
              'Pilih Metode & Petunjuk Pembayaran', 
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 12),
            
            // OPTION 1: TRANSFER VIRTUAL ACCOUNT (BISA DIKLIK)
            _buildExpandableMethodCard(
              index: 0,
              title: 'Transfer Virtual Account (VA)',
              desc: 'Mendukung pembayaran otomatis dari Bank BCA, Mandiri, BNI, atau BRI.',
              icon: Icons.account_balance_rounded,
              child: Column(
                children: [
                  const Divider(color: AppColors.borderColor, height: 20),
                  _buildBankVaRow('Bank BCA Virtual Account', '883012${widget.kodeBooking.replaceAll(RegExp(r'\D'), '')}'),
                  _buildBankVaRow('Bank Mandiri Mandiri Inprofile', '900124${widget.kodeBooking.replaceAll(RegExp(r'\D'), '')}'),
                  _buildBankVaRow('Bank BNI Virtual Account', '460012${widget.kodeBooking.replaceAll(RegExp(r'\D'), '')}'),
                  _buildBankVaRow('Bank BRI BRIVA', '128012${widget.kodeBooking.replaceAll(RegExp(r'\D'), '')}'),
                  const SizedBox(height: 4),
                  Text(
                    '*Salin nomor VA di atas dan masukkan ke dalam aplikasi m-Banking Anda.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // OPTION 2: E-WALLET & SCAN QRIS (BISA DIKLIK)
            _buildExpandableMethodCard(
              index: 1,
              title: 'E-Wallet & Scan QRIS',
              desc: 'Scan barcode QRIS otomatis menggunakan Gopay, OVO, Dana, atau LinkAja.',
              icon: Icons.qr_code_scanner_rounded,
              child: Column(
                children: [
                  const Divider(color: AppColors.borderColor, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderColor, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 130, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'KODE QRIS MITRANS SANDBOX',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                  ),
                  Text(
                    'Simpan atau screenshot QR Code di atas lalu upload di aplikasi e-wallet pilihanmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // TOMBOL AKSI SIMULASI BAYAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSimulating ? null : _prosesSimulasiBayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethodIndex == -1 ? Colors.grey : AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSimulating
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                    : Text('Konfirmasi & Selesaikan Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
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

  // WIDGET KARTU EXPANDABLE (ACCORDION ACTION)
  Widget _buildExpandableMethodCard({
    required int index,
    required String title,
    required String desc,
    required IconData icon,
    required Widget child,
  }) {
    final bool isOpen = _selectedMethodIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Jika diklik pada kartu yang sama maka tutup (-1), jika beda maka buka indeks tersebut
          _selectedMethodIndex = isOpen ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: isOpen ? AppColors.primaryGreen : AppColors.borderColor, width: isOpen ? 2 : 1),
          boxShadow: [
            if (isOpen) BoxShadow(color: AppColors.primaryGreen.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: isOpen ? AppColors.primaryGreen : AppColors.primaryOrange, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      if (!isOpen)
                        Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3)),
                    ],
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            // Jika status kartu terbuka (isOpen == true), render sub-informasinya ke bawah
            if (isOpen) child,
          ],
        ),
      ),
    );
  }

  Widget _buildBankVaRow(String bankName, String noVa) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(bankName, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SelectableText(
            noVa, 
            style: GoogleFonts.spaceMono(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }
}