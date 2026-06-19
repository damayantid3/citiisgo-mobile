import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/paket_camping_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../../../providers/notifikasi_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class BookingCampingScreen extends StatefulWidget {
  final int wisataId;
  const BookingCampingScreen({super.key, required this.wisataId});

  @override
  State<BookingCampingScreen> createState() => _BookingCampingScreenState();
}

class _BookingCampingScreenState extends State<BookingCampingScreen> {
  final _wisataRepo = WisataRepository();
  final _bookingRepo = BookingRepository();
  List<PaketCampingModel> _pakets = [];
  PaketCampingModel? _selected;
  DateTime _checkin = DateTime.now().add(const Duration(days: 1));
  DateTime _checkout = DateTime.now().add(const Duration(days: 2));
  int _jumlahTamu = 1;
  bool _loading = false, _loadingPaket = true;

  @override
  void initState() {
    super.initState();
    _loadPaket();
  }

  Future<void> _loadPaket() async {
    final p = await _wisataRepo.getPaketCamping(widget.wisataId);
    if (mounted) {
      setState(() {
        _loadingPaket = false;
        if (p != null && p.isNotEmpty) {
          _pakets = p;
          _selected = p.first;
        } else {
          _pakets = PaketCampingModel.dummyList();
          _selected = _pakets.first;
        }
      });
    }
  }

  int get _durasi => _checkout.difference(_checkin).inDays.abs().clamp(1, 999);
  int get _total => (_selected?.hargaPerMalam ?? 0) * _durasi;

  Future<void> _pilihTanggal(bool isCheckin) async {
    final first =
        isCheckin ? DateTime.now() : _checkin.add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: isCheckin ? _checkin : _checkout,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
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
    if (_selected == null) return;
    setState(() => _loading = true);

    final r = await _bookingRepo.createBookingCamping({
      'paket_camping_id': _selected!.id,
      'nama_paket': _selected!.namaPaket,
      'tanggal_checkin': _fmtDate(_checkin),
      'tanggal_checkout': _fmtDate(_checkout),
      'jumlah_tamu': _jumlahTamu,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (r['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r['message'] ?? 'Gagal membuat booking camping.',
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
          judul: 'Sewa Camp Menunggu Pembayaran ⏳',
          pesan:
              'Booking ${_selected!.namaPaket} ($kodeBooking) berhasil dibuat. Silakan selesaikan pembayaran tagihan Anda.',
          tipe: 'paket',
        );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PembayaranScreen(
                  paymentUrl: paymentUrl,
                  kodeBooking: kodeBooking,
                  totalHarga: totalHarga,
                  layanan: _selected?.namaPaket ?? 'Booking Area Camping',
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
            child: _loadingPaket
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen, strokeWidth: 3))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaketList(),
                        const SizedBox(height: 24),
                        _buildDateSection(),
                        const SizedBox(height: 24),
                        _buildTamuSection(),
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
            colors: [Color(0xFFEA580C), AppColors.primaryOrange],
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
                  Text('Booking Area Camping',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  Text('Pilih jenis tenda & tanggal reservasi bervakansi',
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

  Widget _buildPaketList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Paket Tersedia',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._pakets.map((p) {
            final isSelected = _selected?.id == p.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selected = p;
                if (_jumlahTamu > p.kapasitasTamu)
                  _jumlahTamu = p.kapasitasTamu;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.borderColor,
                      width: isSelected ? 2 : 1),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0F172A)
                            .withOpacity(isSelected ? 0.04 : 0.01),
                        blurRadius: 12)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF3E0)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Icon(Icons.star_outline_rounded,
                              color: AppColors.primaryOrange, size: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.namaPaket,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _tagChip('👥 Maks ${p.kapasitasTamu} Tamu'),
                              const SizedBox(width: 6),
                              _tagChip('⛺ ${p.totalSlot} Slot'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(CurrencyFormatter.format(p.hargaPerMalam),
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
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
          }).toList(),
        ],
      );

  Widget _buildDateSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durasi Menginap',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _dateTile(
                        'Check-In', _checkin, () => _pilihTanggal(true))),
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.lightOrange,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.nights_stay_rounded,
                      color: AppColors.darkOrange, size: 18),
                  const SizedBox(width: 8),
                  Text('Total Durasi Berkemah: $_durasi Malam',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkOrange,
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

  Widget _buildTamuSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jumlah Peserta Camp',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Row(
              children: [
                _counterBtn(Icons.remove_rounded, _jumlahTamu > 1, () {
                  if (_jumlahTamu > 1) setState(() => _jumlahTamu--);
                }),
                Container(
                    width: 44,
                    alignment: Alignment.center,
                    child: Text('$_jumlahTamu',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary))),
                _counterBtn(Icons.add_rounded,
                    _jumlahTamu < (_selected?.kapasitasTamu ?? 8), () {
                  if (_jumlahTamu < (_selected?.kapasitasTamu ?? 8))
                    setState(() => _jumlahTamu++);
                }),
              ],
            ),
          ],
        ),
      );

  Widget _counterBtn(IconData ico, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color:
                  enabled ? AppColors.primaryOrange : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(ico,
              color: enabled ? Colors.white : AppColors.textMuted, size: 16),
        ),
      );

  Widget _buildSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Tagihan Sewa',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _sumRow('Tipe Paket Camp', _selected?.namaPaket ?? '-'),
            _sumRow('Lama Durasi', '$_durasi Malam'),
            _sumRow('Kuantitas Peserta', '$_jumlahTamu Orang'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
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
                Text('Total Biaya Sewa',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: (_loading || _selected == null) ? null : _booking,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Booking Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      );

  Widget _tagChip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6)),
        child: Text(t,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
      );

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
