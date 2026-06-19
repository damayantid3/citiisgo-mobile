import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/peralatan_model.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

class SewaPeralatanScreen extends StatefulWidget {
  final int wisataId;
  const SewaPeralatanScreen({super.key, required this.wisataId});

  @override
  State<SewaPeralatanScreen> createState() => _SewaPeralatanScreenState();
}

class _SewaPeralatanScreenState extends State<SewaPeralatanScreen> {
  final _wisataRepo = WisataRepository();
  final _apiService = ApiService();
  List<PeralatanModel> _peralatan = [];
  final Map<int, int> _cart = {}; // peralatan_id -> jumlah
  DateTime _mulai = DateTime.now().add(const Duration(days: 1));
  DateTime _selesai = DateTime.now().add(const Duration(days: 2));
  bool _loading = false, _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('[DEBUG SewaAlat] Loading data for Wisata ID: ${widget.wisataId}, mulai: ${_fmtDate(_mulai)}, selesai: ${_fmtDate(_selesai)}');
    try {
      final data = await _wisataRepo.getPeralatan(
        widget.wisataId,
        mulai: _fmtDate(_mulai),
        selesai: _fmtDate(_selesai),
      );
      debugPrint('[DEBUG SewaAlat] Loaded ${data.length} items');
      for (var item in data) {
        debugPrint('[DEBUG SewaAlat] Item: ${item.nama}, stokTersedia: ${item.stokTersedia}');
      }
      if (mounted) {
        setState(() {
          _peralatan = data;
          _loadingData = false;
          
          // Clamp cart quantities to the new available stock
          _cart.removeWhere((id, qty) {
            final itemsFound = _peralatan.where((x) => x.id == id);
            if (itemsFound.isEmpty) {
              return true; // Remove item if it's no longer available
            }
            final available = itemsFound.first.stokTersedia;
            if (qty > available) {
              if (available > 0) {
                _cart[id] = available; // Clamp to max available
              } else {
                return true; // Remove if no stock available
              }
            }
            return false;
          });
        });
      }
    } catch (e, stack) {
      debugPrint('[DEBUG SewaAlat] Error loading data: $e');
      debugPrint('[DEBUG SewaAlat] Stacktrace: $stack');
      if (mounted) {
        setState(() {
          _peralatan = [];
          _loadingData = false;
        });
      }
    }
  }

  int get _durasi => _selesai.difference(_mulai).inDays.abs().clamp(1, 999);

  int get _total {
    int t = 0;
    _cart.forEach((id, qty) {
      final itemsFound = _peralatan.where((x) => x.id == id);
      if (itemsFound.isNotEmpty) {
        // PERBAIKAN: Menyelaraskan pemanggilan properti harga ke 'hargaSewaPerHari'
        t += itemsFound.first.hargaSewaPerHari * qty * _durasi;
      }
    });
    return t;
  }

  List<Map<String, dynamic>> get _cartItems =>
      _cart.entries.where((e) => e.value > 0).map((e) {
        final itemsFound = _peralatan.where((x) => x.id == e.key);
        final namaBarang = itemsFound.isNotEmpty ? itemsFound.first.nama : '-';
        // PERBAIKAN: Menyelaraskan properti harga ke 'hargaSewaPerHari'
        final hargaBarang =
            itemsFound.isNotEmpty ? itemsFound.first.hargaSewaPerHari : 0;
        return {
          'peralatan_id': e.key,
          'jumlah': e.value,
          'nama': namaBarang,
          'harga': hargaBarang
        };
      }).toList();

  Future<void> _pilihTanggal(bool isMulai) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isMulai ? _mulai : _selesai,
      firstDate: isMulai ? DateTime.now() : _mulai.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.purplePrimary),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isMulai) {
          _mulai = d;
          if (!_selesai.isAfter(_mulai))
            _selesai = _mulai.add(const Duration(days: 1));
        } else {
          _selesai = d;
        }
        _loadingData = true;
      });
      await _loadData();
    }
  }

  Future<void> _sewa() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pilih minimal 1 peralatan',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);

    try {
      final res = await _apiService.createSewaPeralatan({
        'wisata_id': widget.wisataId,
        'tanggal_mulai': _fmtDate(_mulai),
        'tanggal_selesai': _fmtDate(_selesai),
        'items': _cartItems
            .map((item) => {
                  'peralatan_id': item['peralatan_id'],
                  'jumlah': item['jumlah'],
                })
            .toList(),
      });

      final data = res.data;
      if (!mounted) return;
      setState(() => _loading = false);

      if (data['success'] == true) {
        final dynamic rawTotal = data['data']?['total_harga'];
        final int totalBayar = rawTotal is int ? rawTotal : (double.tryParse(rawTotal?.toString() ?? '') ?? 0.0).round();
        final String kodeSewa = data['data']?['kode_sewa'] ?? 'ALT-${data['data']?['id'] ?? ''}';
        // Refresh data peralatan agar stok terbaru langsung tampil
        await _loadData();
        if (!mounted) return;
        setState(() => _cart.clear());

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PembayaranScreen(
                      paymentUrl: data['payment_url'] ?? '',
                      kodeBooking: kodeSewa,
                      totalHarga: totalBayar == 0 ? _total : totalBayar,
                      layanan: 'Sewa Alat Logistik Camp',
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Gagal memproses sewa barang',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg =
          e.response?.data['message'] ?? 'Terjadi kesalahan koneksi ke server';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
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
                        color: AppColors.purplePrimary, strokeWidth: 3))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDurationSection(),
                        const SizedBox(height: 24),
                        Text('Katalog Perlengkapan',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        _buildKatalogList(),
                        if (_cartItems.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildInvoiceSummary(),
                        ],
                        const SizedBox(height: 40),
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
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purpleDark, AppColors.purplePrimary],
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
                  Text('Sewa Peralatan',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  Text('Sewa alat camping pelengkap liburanmu',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (_cartItems.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${_cartItems.length} Item',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      );

  Widget _buildDurationSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durasi Peminjaman',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _dateTile(
                        'Mulai Sewa', _mulai, () => _pilihTanggal(true))),
                Container(
                    width: 1,
                    height: 40,
                    color: AppColors.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 14)),
                Expanded(
                    child: _dateTile(
                        'Selesai Sewa', _selesai, () => _pilihTanggal(false))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.av_timer_rounded,
                      color: AppColors.purplePrimary, size: 18),
                  const SizedBox(width: 8),
                  Text('Total Waktu Pemakaian: $_durasi Hari',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: AppColors.purplePrimary,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildKatalogList() => Column(
        children: _peralatan.map((p) {
          final qty = _cart[p.id] ?? 0;
          final isSelected = qty > 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected
                      ? AppColors.purplePrimary
                      : AppColors.borderColor,
                  width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0F172A)
                        .withOpacity(isSelected ? 0.03 : 0.01),
                    blurRadius: 12)
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.purpleLight
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(_getEmoji(p.nama),
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nama,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.textPrimary)),
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
                                  fontWeight: FontWeight.w800)),
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
                          if (qty > 0) _cart[p.id] = qty - 1;
                          if (_cart[p.id] == 0) _cart.remove(p.id);
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColors.purpleLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.remove_rounded,
                              color: AppColors.purplePrimary, size: 14),
                        ),
                      ),
                      Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text('$qty',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary))),
                    ],
                    GestureDetector(
                      onTap: qty < p.stokTersedia
                          ? () => setState(() => _cart[p.id] = qty + 1)
                          : null,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: qty < p.stokTersedia
                                ? AppColors.purplePrimary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8)),
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
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
          children: [
            Row(children: [
              Text('Ringkasan Invoice Peminjaman',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary))
            ]),
            const Divider(color: AppColors.borderColor, height: 24),
            ..._cartItems
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item['nama']} (${item['jumlah']}x)",
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                          Text(
                              CurrencyFormatter.format((item['harga'] as int) *
                                  (item['jumlah'] as int) *
                                  _durasi),
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ))
                .toList(),
            _sumRow('Lama Durasi Pinjam', '$_durasi Hari'),
            const Divider(color: AppColors.borderColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.textPrimary)),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        color: AppColors.primaryGreen)),
              ],
            ),
          ],
        ),
      );

  Widget _buildBottomAction() => Container(
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
                Text('Total Biaya Sewa',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                Text(CurrencyFormatter.format(_total),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purplePrimary)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: (_loading || _cartItems.isEmpty) ? null : _sewa,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplePrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Sewa Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
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
                    fontSize: 11,
                    color: AppColors.purplePrimary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${d.day} ${_bulan(d.month)} ${d.year}',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
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
                fontWeight: FontWeight.w600)),
      );

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            Text(v,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
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
