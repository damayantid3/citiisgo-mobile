import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/kamar_model.dart';
import '../../../data/models/penginapan_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../../../providers/notifikasi_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class BookingPenginapanScreen extends StatefulWidget {
  final int wisataId;
  const BookingPenginapanScreen({super.key, required this.wisataId});

  @override
  State<BookingPenginapanScreen> createState() =>
      _BookingPenginapanScreenState();
}

class _BookingPenginapanScreenState extends State<BookingPenginapanScreen> {
  final _wisataRepo = WisataRepository();
  final _bookingRepo = BookingRepository();
  List<PenginapanModel> _penginapanList = [];
  KamarModel? _selectedKamar;
  PenginapanModel? _selectedPenginapan;
  DateTime _checkin = DateTime.now().add(const Duration(days: 1));
  DateTime _checkout = DateTime.now().add(const Duration(days: 2));
  int _jumlahTamu = 1;
  bool _loading = false, _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _wisataRepo.getPenginapan(widget.wisataId);
    if (mounted) {
      setState(() {
        if (data != null && data.isNotEmpty) {
          _penginapanList = data;
          _selectedPenginapan = data.first;
          if (data.first.kamar.isNotEmpty)
            _selectedKamar = data.first.kamar.first;
        } else {
          final dummyKamar = [
            const KamarModel(
                id: 101,
                tipeKamar: 'Deluxe Room Nature View',
                hargaPerMalam: 350000,
                kapasitas: 2,
                totalKamar: 4,
                tersedia: true),
            const KamarModel(
                id: 102,
                tipeKamar: 'Executive Family Suite',
                hargaPerMalam: 650000,
                kapasitas: 4,
                totalKamar: 2,
                tersedia: true),
          ];
          _penginapanList = [
            PenginapanModel(
                id: 1, nama: 'Citiis Nature Lodge & Resort', kamar: dummyKamar),
          ];
          _selectedPenginapan = _penginapanList.first;
          _selectedKamar = dummyKamar.first;
        }
        _loadingData = false;
      });
    }
  }

  int get _durasi => _checkout.difference(_checkin).inDays.abs().clamp(1, 999);
  int get _total => (_selectedKamar?.hargaPerMalam ?? 0) * _durasi;

  Future<void> _pilihTanggal(bool isCheckin) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isCheckin ? _checkin : _checkout,
      firstDate:
          isCheckin ? DateTime.now() : _checkin.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.info),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isCheckin) {
          _checkin = d;
          if (!_checkout.isAfter(_checkin))
            _checkout = _checkin.add(const Duration(days: 1));
        } else {
          _checkout = d;
        }
      });
    }
  }

  Future<void> _booking() async {
    if (_selectedKamar == null) return;
    setState(() => _loading = true);

    final r = await _bookingRepo.createBookingPenginapan({
      'kamar_id': _selectedKamar!.id,
      'tipe_kamar': _selectedKamar!.tipeKamar,
      'tanggal_checkin': _fmtDate(_checkin),
      'tanggal_checkout': _fmtDate(_checkout),
      'jumlah_tamu': _jumlahTamu,
      'jumlah_kamar': 1,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (r['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r['message'] ?? 'Gagal membuat booking penginapan.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String kodeBooking = r['booking_id'];
    final int totalHarga = r['total_harga'] ?? _total;
    final String paymentUrl = r['payment_url'] ?? '';

    context.read<NotifikasiProvider>().tambahNotifikasi(
          judul: 'Pemesanan Kamar Menunggu Pembayaran ⏳',
          pesan:
              'Booking Kamar ${_selectedKamar!.tipeKamar} ($kodeBooking) berhasil dicatat di sistem. Segera selesaikan transaksi pembayaran.',
          tipe: 'promo',
        );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PembayaranScreen(
                  paymentUrl: paymentUrl,
                  kodeBooking: kodeBooking,
                  totalHarga: totalHarga,
                  layanan: 'Akomodasi Penginapan ${_selectedKamar!.tipeKamar}',
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loadingData
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.info, strokeWidth: 3))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_penginapanList.length > 1) ...[
                          Text('Pilih Hotel / Penginapan',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          ..._buildPenginapanSelector(),
                          const SizedBox(height: 24),
                        ],
                        Text('Pilih Tipe Kamar',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        ..._buildKamarList(),
                        const SizedBox(height: 24),
                        _buildDateSection(),
                        const SizedBox(height: 24),
                        _buildSummary(),
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
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), AppColors.info],
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
                  Text('Booking Kamar Hotel',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  Text('Pilih akomodasi resort & tipe ruangan',
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

  List<Widget> _buildPenginapanSelector() => _penginapanList.map((p) {
        final isSelected = _selectedPenginapan?.id == p.id;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedPenginapan = p;
            _selectedKamar = p.kamar.isNotEmpty ? p.kamar.first : null;
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isSelected ? AppColors.info : AppColors.borderColor,
                  width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                const Text('🏨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(p.nama,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary))),
              ],
            ),
          ),
        );
      }).toList();

  List<Widget> _buildKamarList() => (_selectedPenginapan?.kamar ?? []).map((k) {
        final isSelected = _selectedKamar?.id == k.id;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedKamar = k;
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isSelected ? AppColors.info : AppColors.borderColor,
                  width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.01),
                    blurRadius: 12)
              ],
            ),
            child: Row(
              children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                        child: Icon(Icons.king_bed_rounded,
                            color: AppColors.info, size: 22))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.tipeKamar,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _chip('👥 ${k.kapasitas} Orang'),
                          const SizedBox(width: 6),
                          _chip('🏠 Sisa ${k.totalKamar} Rms'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(k.hargaPerMalam),
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: AppColors.info,
                            fontSize: 14)),
                    Text('/malam',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList();

  Widget _buildDateSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Row(
          children: [
            Expanded(
                child:
                    _dateTile('Check-In', _checkin, () => _pilihTanggal(true))),
            Container(
                width: 1,
                height: 40,
                color: AppColors.borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Expanded(
                child: _dateTile(
                    'Check-Out', _checkout, () => _pilihTanggal(false))),
          ],
        ),
      );

  Widget _dateTile(String lbl, DateTime d, VoidCallback onTap) =>
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
            Text('${d.day} ${_bulan(d.month)} ${d.year}',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          children: [
            _sumRow('Tipe Ruangan', _selectedKamar?.tipeKamar ?? '-'),
            _sumRow('Durasi Sesi', '$_durasi Malam'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.primaryGreen)),
              ],
            ),
          ],
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ]),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Tagihan Hotel',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.info)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    (_loading || _selectedKamar == null) ? null : _booking,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Booking Hotel',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      );

  Widget _chip(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6)),
      child: Text(t,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600)));

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(v,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

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
}
