import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/peralatan_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

class _AlatSewaItem {
  final PeralatanModel peralatan;
  int jumlahSewa;

  _AlatSewaItem({required this.peralatan, this.jumlahSewa = 0});
}

class BookingSewaAlatScreen extends StatefulWidget {
  final int wisataId;
  const BookingSewaAlatScreen({super.key, required this.wisataId});

  @override
  State<BookingSewaAlatScreen> createState() => _BookingSewaAlatScreenState();
}

class _BookingSewaAlatScreenState extends State<BookingSewaAlatScreen> {
  final _bookingRepo = BookingRepository();
  final _wisataRepo = WisataRepository();

  List<_AlatSewaItem> _katalogAlat = [];
  bool _loadingKatalog = true;
  bool _isSubmitting = false;

  DateTime _tanggalMulai = DateTime.now().add(const Duration(days: 1));
  DateTime _tanggalSelesai = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    super.initState();
    _loadKatalog();
  }

  Future<void> _loadKatalog() async {
    final peralatan = await _wisataRepo.getPeralatan(widget.wisataId);
    if (!mounted) return;
    setState(() {
      _katalogAlat = peralatan.map((p) => _AlatSewaItem(peralatan: p)).toList();
      _loadingKatalog = false;
    });
  }

  int get _durasiHari =>
      _tanggalSelesai.difference(_tanggalMulai).inDays.abs().clamp(1, 999);

  int get _hitungTotalHarga {
    int total = 0;
    for (var item in _katalogAlat) {
      total += item.jumlahSewa * item.peralatan.hargaSewaPerHari;
    }
    return total * _durasiHari;
  }

  int get _totalItemSewa {
    return _katalogAlat.fold(0, (prev, element) => prev + element.jumlahSewa);
  }

  String get _buatRingkasanTeks {
    List<String> tersewa = [];
    for (var item in _katalogAlat) {
      if (item.jumlahSewa > 0)
        tersewa.add('${item.peralatan.nama} (${item.jumlahSewa}x)');
    }
    return tersewa.isEmpty ? 'Sewa Alat Camp' : tersewa.join(', ');
  }

  Future<void> _pilihTanggal(bool isMulai) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isMulai ? _tanggalMulai : _tanggalSelesai,
      firstDate:
          isMulai ? DateTime.now() : _tanggalMulai.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF059669)),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = d;
          if (!_tanggalSelesai.isAfter(_tanggalMulai)) {
            _tanggalSelesai = _tanggalMulai.add(const Duration(days: 1));
          }
        } else {
          _tanggalSelesai = d;
        }
      });
    }
  }

  Future<void> _prosesBookingAlat() async {
    if (_hitungTotalHarga == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih minimal 1 alat camping untuk disewa!'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final items = _katalogAlat
        .where((item) => item.jumlahSewa > 0)
        .map((item) => {
              'peralatan_id': item.peralatan.id,
              'jumlah': item.jumlahSewa,
            })
        .toList();

    final res = await _bookingRepo.createBookingAlat({
      'wisata_id': widget.wisataId,
      'tanggal_mulai': _fmtDate(_tanggalMulai),
      'tanggal_selesai': _fmtDate(_tanggalSelesai),
      'items': items,
      'durasi': _durasiHari,
      'total_item': _totalItemSewa,
      'ringkasan_alat': _buatRingkasanTeks,
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PembayaranScreen(
                    paymentUrl: res['payment_url'] ?? '',
                    kodeBooking: res['booking_id'],
                    totalHarga: res['total_harga'] ?? _hitungTotalHarga,
                    layanan: 'Sewa Peralatan Outbond & Camp',
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal membuat sewa alat.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _bulan(int m) => [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopHeader(),
          Expanded(
            child: _loadingKatalog
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF059669), strokeWidth: 3))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDurasiSewaWidget(),
                        const SizedBox(height: 24),
                        Text('Katalog Peralatan Tersedia',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        _katalogAlat.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                      'Belum ada peralatan tersedia untuk wisata ini.',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary)),
                                ),
                              )
                            : _buildListKatalogCard(),
                        const SizedBox(height: 24),
                        _buildKalkulasiTotalWidget(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
          _buildFooterAksi(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Penyewaan Alat Camp',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  Text('Lengkapi logistik & kenyamanan berkemahmu',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildDurasiSewaWidget() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Periode Peminjaman',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('Tarif dihitung per 24 jam',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _dateTile(
                        'Mulai', _tanggalMulai, () => _pilihTanggal(true))),
                Container(
                    width: 1,
                    height: 40,
                    color: AppColors.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 14)),
                Expanded(
                    child: _dateTile('Selesai', _tanggalSelesai,
                        () => _pilihTanggal(false))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Text('Total Durasi Sewa: $_durasiHari Hari',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _dateTile(String lbl, DateTime date, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lbl,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${date.day} ${_bulan(date.month)} ${date.year}',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildListKatalogCard() => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _katalogAlat.length,
        itemBuilder: (context, idx) {
          final item = _katalogAlat[idx];
          final p = item.peralatan;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Icon(Icons.handyman_rounded,
                          color: Color(0xFF059669), size: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nama,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                          '${CurrencyFormatter.format(p.hargaSewaPerHari)} / hari · Stok ${p.stokTersedia}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _counterButton(Icons.remove_rounded, item.jumlahSewa > 0,
                        () {
                      if (item.jumlahSewa > 0)
                        setState(() => item.jumlahSewa--);
                    }),
                    Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Text('${item.jumlahSewa}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary))),
                    _counterButton(
                        Icons.add_rounded, item.jumlahSewa < p.stokTersedia,
                        () {
                      if (item.jumlahSewa < p.stokTersedia)
                        setState(() => item.jumlahSewa++);
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      );

  Widget _buildKalkulasiTotalWidget() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Biaya Logistik',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _summaryRow('Kuantitas Unit Barang', '$_totalItemSewa Item'),
            _summaryRow('Lama Peminjaman', '$_durasiHari Hari'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Biaya Sewa Alat',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.textPrimary)),
                Text(CurrencyFormatter.format(_hitungTotalHarga),
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: const Color(0xFF059669))),
              ],
            ),
          ],
        ),
      );

  Widget _counterButton(IconData ico, bool active, VoidCallback tap) =>
      GestureDetector(
        onTap: active ? tap : null,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: active ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(ico,
              color: active ? Colors.white : AppColors.textMuted, size: 14),
        ),
      );

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildFooterAksi() => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ]),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Estimasi Sewa Alat',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                Text(CurrencyFormatter.format(_hitungTotalHarga),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _hitungTotalHarga == 0)
                    ? null
                    : _prosesBookingAlat,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Sewa Alat Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      );
}
