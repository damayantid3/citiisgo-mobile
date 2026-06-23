import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/peralatan_model.dart';
import '../../../data/repositories/booking_repository_api.dart'; // ✅ GANTI ke API
import '../../../data/repositories/wisata_repository.dart';
import '../../../providers/notifikasi_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class SewaPeralatanScreen extends StatefulWidget {
  final int wisataId;
  const SewaPeralatanScreen({super.key, required this.wisataId});

  @override
  State<SewaPeralatanScreen> createState() => _SewaPeralatanScreenState();
}

class _SewaPeralatanScreenState extends State<SewaPeralatanScreen> {
  final _wisataRepo  = WisataRepository();
  final _bookingRepo = BookingRepositoryApi(); // ✅ API
  List<PeralatanModel> _peralatan = [];
  final Map<int, int> _cart = {}; // peralatan_id → jumlah
  DateTime _mulai   = DateTime.now().add(const Duration(days: 1));
  DateTime _selesai = DateTime.now().add(const Duration(days: 2));
  bool _loading = false, _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // ✅ Load dari API → /wisata/{id}/peralatan
      final data = await _wisataRepo.getPeralatan(widget.wisataId);
      if (mounted) {
        setState(() {
          _peralatan = (data != null && data.isNotEmpty)
              ? data
              : _fallbackPeralatan();
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _peralatan    = _fallbackPeralatan();
          _loadingData  = false;
        });
      }
    }
  }

  List<PeralatanModel> _fallbackPeralatan() => [
        const PeralatanModel(id: 1, nama: 'Tenda Dome Waterproof 4P',
            hargaSewaPerHari: 45000, totalStok: 10, stokTersedia: 10),
        const PeralatanModel(id: 2, nama: 'Sleeping Bag Thermal Wool',
            hargaSewaPerHari: 15000, totalStok: 15, stokTersedia: 15),
        const PeralatanModel(id: 3, nama: 'Matras Camping Spons',
            hargaSewaPerHari: 7000, totalStok: 20, stokTersedia: 20),
        const PeralatanModel(id: 4, nama: 'Kompor Portable & Gas Mini',
            hargaSewaPerHari: 25000, totalStok: 8, stokTersedia: 8),
        const PeralatanModel(id: 5, nama: 'Lampu Tenda LED',
            hargaSewaPerHari: 10000, totalStok: 12, stokTersedia: 12),
        const PeralatanModel(id: 6, nama: 'Carrier Backpack 60L',
            hargaSewaPerHari: 35000, totalStok: 6, stokTersedia: 6),
      ];

  int get _durasi => _selesai.difference(_mulai).inDays.abs().clamp(1, 999);

  int get _total {
    int t = 0;
    _cart.forEach((id, qty) {
      final item = _peralatan.where((x) => x.id == id);
      if (item.isNotEmpty) t += item.first.hargaSewaPerHari * qty * _durasi;
    });
    return t;
  }

  List<Map<String, dynamic>> get _cartItems => _cart.entries
      .where((e) => e.value > 0)
      .map((e) {
        final item = _peralatan.where((x) => x.id == e.key);
        return {
          'peralatan_id': e.key,
          'jumlah'      : e.value,
          'nama'        : item.isNotEmpty ? item.first.nama : '-',
          'harga'       : item.isNotEmpty ? item.first.hargaSewaPerHari : 0,
        };
      }).toList();

  Future<void> _pilihTanggal(bool isMulai) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isMulai ? _mulai : _selesai,
      firstDate: isMulai
          ? DateTime.now()
          : _mulai.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.purplePrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isMulai) {
          _mulai = d;
          if (!_selesai.isAfter(_mulai)) {
            _selesai = _mulai.add(const Duration(days: 1));
          }
        } else {
          _selesai = d;
        }
      });
    }
  }

  Future<void> _sewa() async {
    if (_cartItems.isEmpty) return;
    setState(() => _loading = true);

    // ✅ Kirim ke API nyata
    final items = _cartItems
        .map((e) => {'peralatan_id': e['peralatan_id'], 'jumlah': e['jumlah']})
        .toList();

    final r = await _bookingRepo.createBookingAlat({
      'tanggal_mulai'  : _fmtDate(_mulai),
      'tanggal_selesai': _fmtDate(_selesai),
      'durasi_hari'    : _durasi,
      'items'          : items,
      'total_harga'    : _total,
    });

    if (!mounted) return;
    setState(() => _loading = false);

    // ✅ Notifikasi lokal
    context.read<NotifikasiProvider>().tambahNotifikasi(
      judul: 'Sewa Peralatan Berhasil! 🎒',
      pesan :
          '${_cartItems.length} item selama $_durasi hari senilai ${CurrencyFormatter.format(_total)} berhasil dipesan.',
      tipe: 'paket',
    );

    final String bookingId = (r['success'] == true)
        ? (r['booking_id'] ?? 'BWA-${DateTime.now().millisecondsSinceEpoch}')
        : 'BWA-${DateTime.now().millisecondsSinceEpoch}';

    final String payUrl = (r['success'] == true)
        ? (r['payment_url'] ?? '')
        : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$bookingId';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PembayaranScreen(
          paymentUrl  : payUrl,
          kodeBooking : bookingId,
          totalHarga  : _total,
          layanan     : 'Sewa Peralatan Camping',
        ),
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
            child: _loadingData
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.purplePrimary,
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateSection(),
                        const SizedBox(height: 20),
                        _buildSectionLabel('Pilih Peralatan'),
                        const SizedBox(height: 12),
                        _buildPeralatanList(),
                        if (_cartItems.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildInvoiceSummary(),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A0080), AppColors.purplePrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
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
                  Text('Sewa Peralatan Camping',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3,
                      )),
                  Text('Lengkapi perlengkapan petualanganmu',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70, fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
            if (_cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_cartItems.length} item',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildSectionLabel(String t) => Text(
        t,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      );

  Widget _buildDateSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durasi Penyewaan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _dateTile('Mulai', _mulai,
                    () => _pilihTanggal(true))),
                Container(
                    width: 1, height: 40,
                    color: AppColors.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 14)),
                Expanded(child: _dateTile('Selesai', _selesai,
                    () => _pilihTanggal(false))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded,
                      color: AppColors.purplePrimary, size: 16),
                  const SizedBox(width: 8),
                  Text('Total Durasi Pinjam: $_durasi Hari',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.purplePrimary, fontSize: 12.5,
                      )),
                ],
              ),
            ),
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
                  fontSize: 11, color: AppColors.purplePrimary,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 4),
            Text('${d.day} ${_bulan(d.month)} ${d.year}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 14,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      );

  Widget _buildPeralatanList() => Column(
        children: _peralatan.map((p) {
          final qty = _cart[p.id] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: qty > 0
                    ? AppColors.purplePrimary
                    : AppColors.borderColor,
                width: qty > 0 ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: qty > 0
                        ? AppColors.purpleLight
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(_getEmoji(p.nama),
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _chip('Stok: ${p.stokTersedia}'),
                          const SizedBox(width: 8),
                          Text(
                            '${CurrencyFormatter.format(p.hargaSewaPerHari)}/hari',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.purplePrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    if (qty > 0) ...[
                      GestureDetector(
                        onTap: () => setState(() {
                          _cart[p.id] = qty - 1;
                          if (_cart[p.id] == 0) _cart.remove(p.id);
                        }),
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.purpleLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove_rounded,
                              color: AppColors.purplePrimary, size: 14),
                        ),
                      ),
                      Container(
                        width: 32, alignment: Alignment.center,
                        child: Text('$qty',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            )),
                      ),
                    ],
                    GestureDetector(
                      onTap: qty < p.stokTersedia
                          ? () => setState(() => _cart[p.id] = qty + 1)
                          : null,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: qty < p.stokTersedia
                              ? AppColors.purplePrimary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: qty < p.stokTersedia
                                ? Colors.white
                                : AppColors.textMuted,
                            size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );

  Widget _buildInvoiceSummary() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Invoice',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 14,
                  color: AppColors.textPrimary,
                )),
            const Divider(color: AppColors.borderColor, height: 20),
            ..._cartItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['nama']} (${item['jumlah']}x)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5, color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                            (item['harga'] as int) *
                                (item['jumlah'] as int) *
                                _durasi),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
            _sumRow('Durasi Pinjam', '$_durasi Hari'),
            const Divider(color: AppColors.borderColor, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 14,
                      color: AppColors.textPrimary,
                    )),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 16,
                      color: AppColors.primaryGreen,
                    )),
              ],
            ),
          ],
        ),
      );

  Widget _buildBottomAction() => Container(
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Biaya Sewa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    )),
                Text(
                  _cartItems.isEmpty
                      ? 'Rp 0'
                      : CurrencyFormatter.format(_total),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.purplePrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160, height: 48,
              child: ElevatedButton(
                onPressed: (_loading || _cartItems.isEmpty) ? null : _sewa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purplePrimary,
                  disabledBackgroundColor: AppColors.borderColor,
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
                    : Text(
                        _cartItems.isEmpty
                            ? 'Pilih Item'
                            : 'Sewa Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(t,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
      );

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 8),
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

  String _getEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('tenda')) return '⛺';
    if (n.contains('sleeping') || n.contains('bag')) return '💤';
    if (n.contains('carrier') || n.contains('backpack')) return '🎒';
    if (n.contains('kompor')) return '🏕️';
    if (n.contains('lampu') || n.contains('lamp')) return '💡';
    if (n.contains('matras')) return '🧗';
    return '🔧';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _bulan(int m) => [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ][m];
}