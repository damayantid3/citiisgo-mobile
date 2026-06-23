import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/booking_repository_api.dart'; // ✅ GANTI
import '../../../providers/notifikasi_provider.dart';
import '../../../providers/booking_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class ReservasiScreen extends StatefulWidget {
  final WisataModel wisata;
  const ReservasiScreen({super.key, required this.wisata});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  // ✅ GANTI dari BookingRepository → BookingRepositoryApi
  final _repo = BookingRepositoryApi();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _jumlahTiket = 1;
  bool _loading = false;

  // ✅ Harga dari API (WisataModel), bukan hardcode
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

    // ✅ Kirim ke API nyata via BookingRepositoryApi
    final result = await _repo.createBookingTiket({
      'tanggal_kunjungan': _fmtDate(_selectedDate),
      'jumlah_tiket'     : _jumlahTiket,
      'total_harga'      : _totalHarga,
      'wisata_id'        : widget.wisata.id,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      // ✅ Notifikasi lokal
      context.read<NotifikasiProvider>().tambahNotifikasi(
        judul: 'Reservasi Tiket Berhasil! 🎉',
        pesan : '${_jumlahTiket} tiket masuk ${widget.wisata.nama} senilai '
            '${CurrencyFormatter.format(_totalHarga)} berhasil dibuat. '
            'Segera selesaikan pembayaran.',
        tipe: 'sukses',
      );

      // ✅ Refresh riwayat booking
      context.read<BookingProvider>().refresh();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PembayaranScreen(
            paymentUrl  : result['payment_url'] ?? '',
            kodeBooking : result['booking_id'] ?? 'TKT-000',
            totalHarga  : _totalHarga,
            layanan     : 'Tiket Masuk ${widget.wisata.nama}',
          ),
        ),
      );
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg ?? 'Gagal membuat reservasi tiket',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildWisataCard(),
                  const SizedBox(height: 20),
                  _buildTanggalPicker(),
                  const SizedBox(height: 20),
                  _buildJumlahTiket(),
                  const SizedBox(height: 20),
                  _buildInvoice(),
                  const SizedBox(height: 16),
                  _buildInfoTip(),
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
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
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
                        Text('Reservasi Tiket',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white, fontSize: 17,
                              fontWeight: FontWeight.w800, letterSpacing: -0.3,
                            )),
                        Text(widget.wisata.nama,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70, fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
      );

  Widget _buildWisataCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(widget.wisata.emoji ?? '🏔️',
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.wisata.nama,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 14,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 4),
                  Text('📍 ${widget.wisata.alamat}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text('${widget.wisata.rating}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      const SizedBox(width: 8),
                      // ✅ Harga dari API
                      Text(
                        '${CurrencyFormatter.format(widget.wisata.hargaTiket)} / orang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTanggalPicker() => GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primaryGreen, size: 24),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal Kunjungan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(_formatDate(_selectedDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      )),
                  Text(_getDayName(_selectedDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_calendar_rounded,
                  color: AppColors.primaryGreen, size: 18),
            ],
          ),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah Tiket',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 14,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    '${CurrencyFormatter.format(widget.wisata.hargaTiket)} / orang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _jumlahTiket > 1
                      ? () => setState(() => _jumlahTiket--)
                      : null,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _jumlahTiket > 1
                          ? AppColors.lightGreen
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _jumlahTiket > 1
                            ? AppColors.primaryGreen
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Icon(Icons.remove_rounded,
                        color: _jumlahTiket > 1
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                        size: 18),
                  ),
                ),
                Container(
                  width: 48, alignment: Alignment.center,
                  child: Text('$_jumlahTiket',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      )),
                ),
                GestureDetector(
                  onTap: _jumlahTiket < 50
                      ? () => setState(() => _jumlahTiket++)
                      : null,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildInvoice() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Row(children: [
              Text('Detail Pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, fontSize: 14,
                    color: AppColors.textPrimary,
                  )),
            ]),
            const Divider(color: AppColors.borderColor, height: 24),
            _summaryRow('Harga Tiket',
                CurrencyFormatter.format(widget.wisata.hargaTiket)),
            _summaryRow('Jumlah', '$_jumlahTiket Orang'),
            _summaryRow('Tanggal', _formatDate(_selectedDate)),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan',
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

  Widget _buildInfoTip() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFE082).withOpacity(0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'E-ticket resmi akan diterbitkan secara otomatis setelah pembayaran terkonfirmasi. '
                'Tunjukkan e-ticket kepada petugas loket saat tiba di gerbang utama.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w500, height: 1.5,
                ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Tagihan',
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
            SizedBox(
              width: 160, height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _booking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
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
                    : Text('Lanjut ke Bayar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
              ),
            ),
          ],
        ),
      );

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _stepBadge(String num, String lbl, bool active, bool done) => Column(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active || done
                  ? Colors.white
                  : Colors.white.withOpacity(.25),
            ),
            child: Center(
              child: done && !active
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primaryGreen, size: 14)
                  : Text(num,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: active ? AppColors.primaryGreen : Colors.white70,
                      )),
            ),
          ),
          const SizedBox(height: 4),
          Text(lbl,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: active ? Colors.white : Colors.white54,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              )),
        ],
      );

  Widget _stepLine(bool done) => Container(
        height: 2, width: 36,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: done ? Colors.white : Colors.white.withOpacity(.25),
      );

  Widget _summaryRow(String key, String val) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
            Text(val,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      );

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  String _getDayName(DateTime d) => const [
        '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ][d.weekday];
}