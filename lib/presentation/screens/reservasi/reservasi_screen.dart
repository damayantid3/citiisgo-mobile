import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

class ReservasiScreen extends StatefulWidget {
  final WisataModel wisata;
  const ReservasiScreen({super.key, required this.wisata});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  final _repo = BookingRepository();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _jumlahTiket = 1;
  bool _loading = false;

  int get _totalHarga => widget.wisata.hargaTiket * _jumlahTiket;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
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
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _booking() async {
    setState(() => _loading = true);

    final result = await _repo.createBookingTiket({
      'wisata_id': widget.wisata.id,
      'tanggal_kunjungan':
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      'jumlah_tiket': _jumlahTiket,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PembayaranScreen(
              paymentUrl: result['payment_url'] ?? '',
              kodeBooking: result['booking_id'] ?? '',
              totalHarga: result['total_harga'] ?? _totalHarga,
              layanan: 'Reservasi Tiket Masuk ${widget.wisata.nama}',
            ),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal membuat reservasi.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg ?? 'Gagal membuat reservasi tiket',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Gradien Premium CitiisGo
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
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
                            Text('Reservasi Tiket',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3)),
                            Text(widget.wisata.nama,
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress Steps indicator bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stepBadge('1', 'Detail', true, true),
                      _stepLine(true),
                      _stepBadge('2', 'Bayar', false, false),
                      _stepLine(false),
                      _stepBadge('3', 'Selesai', false, false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Kartu Info Destinasi Wisata
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.borderColor.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(14)),
                          child: Center(
                              child: Text(widget.wisata.emoji ?? '🏔️',
                                  style: const TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.wisata.nama,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(
                                  '📍 ${widget.wisata.alamat ?? "Tasikmalaya"}',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text('${widget.wisata.rating}',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary)),
                                  Text('  •  ',
                                      style: TextStyle(
                                          color: AppColors.textMuted
                                              .withOpacity(0.5))),
                                  Text(
                                      '${CurrencyFormatter.format(widget.wisata.hargaTiket)} / orang',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kalender Pilihan Jadwal Kunjungan
                  _sectionCard(
                    'Jadwal Kedatangan Wisata',
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primaryGreen, size: 24),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatDate(_selectedDate),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryGreen)),
                                const SizedBox(height: 2),
                                Text(_getDayName(_selectedDate),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_calendar_rounded,
                                color: AppColors.primaryGreen, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Counter Jumlah Kuantitas Tiket masuk
                  _sectionCard(
                    'Kuantitas Tiket Masuk',
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_jumlahTiket > 1)
                              setState(() => _jumlahTiket--);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _jumlahTiket > 1
                                  ? AppColors.lightGreen
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _jumlahTiket > 1
                                      ? AppColors.primaryGreen
                                      : AppColors.borderColor),
                            ),
                            child: Icon(Icons.remove_rounded,
                                color: _jumlahTiket > 1
                                    ? AppColors.primaryGreen
                                    : AppColors.textMuted,
                                size: 18),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$_jumlahTiket',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_jumlahTiket < 20)
                              setState(() => _jumlahTiket++);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                            '× ${CurrencyFormatter.format(widget.wisata.hargaTiket)}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rincian Tagihan Invoice Manifes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.borderColor.withOpacity(0.6))),
                    child: Column(
                      children: [
                        Row(children: [
                          Text('Detail Manifes Pembayaran',
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary))
                        ]),
                        const Divider(color: AppColors.borderColor, height: 24),
                        _summaryRow('Tarif Tiket Masuk',
                            CurrencyFormatter.format(widget.wisata.hargaTiket)),
                        _summaryRow(
                            'Kuantitas Pengunjung', '$_jumlahTiket Orang'),
                        _summaryRow(
                            'Sesi Kunjungan', _formatDate(_selectedDate)),
                        const Divider(color: AppColors.borderColor, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Invoice',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.textPrimary)),
                            Text(CurrencyFormatter.format(_totalHarga),
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.primaryGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informasi Edukatif Sistem Pembayaran
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFFFE082).withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Gerbang transaksi ditenagai oleh Midtrans Virtual Account. E-ticket resmi akan langsung diterbitkan secara otomatis setelah proses pembayaran terkonfirmasi lunas.',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFFB45309),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action Floating Button bawah
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 20,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total Tagihan',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600)),
                    Text(CurrencyFormatter.format(_totalHarga),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen)),
                  ],
                ),
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _booking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : Text('Lanjut ke Bayar',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBadge(String num, String lbl, bool active, bool done) => Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active || done
                    ? Colors.white
                    : Colors.white.withOpacity(.25)),
            child: Center(
              child: done && !active
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primaryGreen, size: 14)
                  : Text(num,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? AppColors.primaryGreen
                              : Colors.white70)),
            ),
          ),
          const SizedBox(height: 4),
          Text(lbl,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: active ? Colors.white : Colors.white54,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
        ],
      );

  Widget _stepLine(bool done) => Container(
        height: 2,
        width: 36,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: done ? Colors.white : Colors.white.withOpacity(.25),
      );

  Widget _sectionCard(String title, Widget content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary)),
          ),
          content,
        ],
      );

  Widget _summaryRow(String key, String val) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(val,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

  // PERBAIKAN: Memastikan penulisan method fungsi pembantu diletakkan dengan benar di dalam cakupan State class
  String _formatDate(DateTime d) {
    final months = [
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
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  String _getDayName(DateTime d) => [
        '',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ][d.weekday];
}
