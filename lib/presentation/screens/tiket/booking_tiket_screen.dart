import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../providers/notifikasi_provider.dart'; // Import provider notifikasi baru
import '../../../data/models/wisata_model.dart';
import '../../../providers/wisata_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class BookingTiketScreen extends StatefulWidget {
  final int wisataId;
  const BookingTiketScreen({super.key, required this.wisataId});

  @override
  State<BookingTiketScreen> createState() => _BookingTiketScreenState();
}

class _BookingTiketScreenState extends State<BookingTiketScreen> {
  final _bookingRepo = BookingRepository();
  int _jumlahTiket = 1;
  int _hargaTiket = 20000; 
  String _wisataNama = 'Kawasan Wisata Gunung Citiis';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;

  int get _totalHarga => _jumlahTiket * _hargaTiket;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wisataP = Provider.of<WisataProvider>(context, listen: false);
      final allList = wisataP.allWisata.where((w) => w.id == widget.wisataId);
      final filteredList = wisataP.filteredWisata.where((w) => w.id == widget.wisataId);
      final WisataModel? wisata = allList.isNotEmpty
          ? allList.first
          : (filteredList.isNotEmpty ? filteredList.first : null);
      if (wisata != null) {
        setState(() {
          _wisataNama = wisata.nama;
          _hargaTiket = wisata.hargaTiket;
        });
      }
    });
  }

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; });
    }
  }

  Future<void> _prosesBookingTiket() async {
    setState(() => _loading = true);

    try {
      final r = await _bookingRepo.createBookingTiket({
        'wisata_id': widget.wisataId,
        'tanggal_kunjungan': _fmtDate(_selectedDate),
        'jumlah_tiket': _jumlahTiket,
        'total_harga': _totalHarga, 
      });

      if (!mounted) return;
      setState(() => _loading = false);

      if (r != null && r['success'] == true) {
        // INTEGRASI NOTIFIKASI DINAMIS: Menambahkan data riwayat aktivitas booking tiket secara realtime
        context.read<NotifikasiProvider>().tambahNotifikasi(
          judul: 'Pemesanan Tiket Berhasil! 🎉',
          pesan: 'Tiket Masuk Utama Wisata Citiis sebanyak $_jumlahTiket Orang senilai ${CurrencyFormatter.format(_totalHarga)} berhasil dibuat. Silakan selesaikan pembayaran.',
          tipe: 'sukses',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PembayaranScreen(
              paymentUrl: r['payment_url'] ?? '',
              kodeBooking: r['booking_id'] ?? 'TKT-${DateTime.now().millisecondsSinceEpoch}',
              totalHarga: _totalHarga,
              layanan: 'Tiket Masuk Utama Wisata Citiis',
            ),
          ),
        );
      } else {
        _showSnackBarError(r['message'] ?? 'Gagal memproses data tiket masuk.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBarError('Koneksi gagal atau terjadi kesalahan penafsiran data: $e');
    }
  }

  void _showSnackBarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoWisataCard(),
                  const SizedBox(height: 24),
                  _buildTanggalKunjungan(),
                  const SizedBox(height: 24),
                  _buildJumlahTiket(),
                  const SizedBox(height: 24),
                  _buildSummary(),
                  const SizedBox(height: 30),
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
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.white.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Tiket Masuk', style: GoogleFonts.plusJakartaSans(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  Text('Pesan tiket masuk wisata alam lebih praktis', style: GoogleFonts.plusJakartaSans(color: AppColors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildInfoWisataCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor)),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('🎟️', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_wisataNama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Tiket berlaku untuk 1 orang / 1 kali masuk', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTanggalKunjungan() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal Kunjungan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${_selectedDate.day} ${_bulan(_selectedDate.month)} ${_selectedDate.year}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _pilihTanggal,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreen, foregroundColor: AppColors.primaryGreen, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: Text('Ubah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
            )
          ],
        ),
      );

  Widget _buildJumlahTiket() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah Tiket', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${CurrencyFormatter.format(_hargaTiket)} / orang', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              children: [
                _counterBtn(Icons.remove_rounded, _jumlahTiket > 1, () { if (_jumlahTiket > 1) setState(() => _jumlahTiket--); }),
                Container(width: 40, alignment: Alignment.center, child: Text('$_jumlahTiket', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                _counterBtn(Icons.add_rounded, _jumlahTiket < 50, () { setState(() => _jumlahTiket++); }),
              ],
            ),
          ],
        ),
      );

  Widget _counterBtn(IconData ico, bool enabled, VoidCallback onTap) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: enabled ? AppColors.primaryGreen : AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Icon(ico, color: enabled ? Colors.white : AppColors.textMuted, size: 14),
        ),
      );

  Widget _buildSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pembayaran', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _sumRow('Harga Satuan Tiket', CurrencyFormatter.format(_hargaTiket)),
            _sumRow('Kuantitas Tiket', '$_jumlahTiket Orang'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
                Text(CurrencyFormatter.format(_totalHarga), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.primaryGreen)),
              ],
            ),
          ],
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 20, offset: const Offset(0, -4))]),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Biaya Tiket', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                Text(CurrencyFormatter.format(_totalHarga), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160, height: 46,
              child: ElevatedButton(
                onPressed: _loading ? null : _prosesBookingTiket,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text('Beli Tiket Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      );

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      );

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _bulan(int m) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'][m];
}