import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository_api.dart'; // ✅ GANTI
import '../../../providers/booking_provider.dart';               // ✅ GANTI
import '../../../providers/notifikasi_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  // ✅ GANTI dari BookingRepository (lokal) → BookingRepositoryApi (API nyata)
  final _bookingRepo = BookingRepositoryApi();
  late TabController _tabCtrl;

  // Filter tipe aktif
  String _filterTipe = 'Semua';
  final List<String> _tipes = [
    'Semua', 'Tiket Masuk', 'Sewa Camp', 'Penginapan', 'Sewa Alat',
  ];

  static const _green  = Color(0xFF0F7133);
  static const _orange = Color(0xFFFF7A00);
  static const _slate9 = Color(0xFF0F172A);
  static const _slate5 = Color(0xFF64748B);
  static const _slate2 = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    // ✅ Load riwayat dari API via BookingProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadRiwayat();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Filter helper ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _byTab(
    List<Map<String, dynamic>> all, String tab,
  ) {
    List<Map<String, dynamic>> result;
    switch (tab) {
      case 'pending':
        result = all.where((t) =>
            t['status'] == 'Belum Dibayar' ||
            t['status'] == 'pending').toList();
        break;
      case 'active':
        result = all.where((t) =>
            t['status'] == 'Lunas' ||
            t['status'] == 'Terkonfirmasi' ||
            t['status'] == 'confirmed' ||
            t['status'] == 'paid').toList();
        break;
      default:
        result = all.where((t) =>
            t['status'] == 'Dibatalkan' ||
            t['status'] == 'Selesai' ||
            t['status'] == 'cancelled' ||
            t['status'] == 'completed').toList();
    }
    // Filter tipe tambahan
    if (_filterTipe != 'Semua') {
      result = result
          .where((t) => t['tipe'] == _filterTipe)
          .toList();
    }
    return result;
  }

  // ── Batalkan booking via API ──────────────────────────────────────────────
  Future<void> _cancelBooking(Map<String, dynamic> tiket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Batalkan Reservasi?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: _slate9,
            )),
        content: Text(
          'Yakin ingin membatalkan "${tiket['layanan']}"?\n'
          'Proses ini tidak dapat diurungkan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: _slate5, height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Tidak',
                style: GoogleFonts.plusJakartaSans(color: _slate5)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text('Ya, Batalkan',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // ✅ Kirim pembatalan ke API
    final ok = await _bookingRepo.cancelBooking(
      tiket['tipe'] as String,
      int.tryParse(tiket['id'].toString()) ?? 0,
    );

    if (!mounted) return;

    if (ok) {
      // ✅ Notifikasi lokal
      context.read<NotifikasiProvider>().tambahNotifikasi(
        judul: 'Reservasi Dibatalkan ❌',
        pesan: '${tiket['layanan']} (${tiket['id']}) '
            'telah berhasil dibatalkan.',
        tipe: 'batal',
      );
      // ✅ Refresh riwayat dari API
      context.read<BookingProvider>().refresh();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reservasi berhasil dibatalkan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal membatalkan. Coba lagi.',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Riwayat Pemesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w800, color: _slate9,
            )),
        actions: [
          // ✅ Tombol refresh manual
          Consumer<BookingProvider>(
            builder: (_, bp, __) => IconButton(
              onPressed: bp.isLoading ? null : () => bp.refresh(),
              icon: bp.isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: _green,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded,
                      color: _green, size: 22),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _green,
          unselectedLabelColor: _slate5,
          indicatorColor: _green,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Tiket Aktif'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Filter Tipe ──
          _buildFilterChips(),

          // ── Konten Tab dari API ──
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (_, bp, __) {
                if (bp.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _green, strokeWidth: 3,
                    ),
                  );
                }

                if (bp.error != null) {
                  return _buildErrorState(bp.error!, bp.refresh);
                }

                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(_byTab(bp.riwayat, 'pending'), 'pending'),
                    _buildList(_byTab(bp.riwayat, 'active'), 'active'),
                    _buildList(_byTab(bp.riwayat, 'history'), 'history'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips tipe ─────────────────────────────────────────────────────
  Widget _buildFilterChips() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _tipes.map((t) {
              final sel = _filterTipe == t;
              return GestureDetector(
                onTap: () => setState(() => _filterTipe = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? _green : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(t,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : _slate5,
                      )),
                ),
              );
            }).toList(),
          ),
        ),
      );

  // ── ListView riwayat ──────────────────────────────────────────────────────
  Widget _buildList(List<Map<String, dynamic>> list, String tab) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<BookingProvider>().refresh(),
        color: _green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tab == 'pending' ? '🕐' : tab == 'active' ? '🎫' : '📋',
                    style: const TextStyle(fontSize: 52),
                  ),
                  const SizedBox(height: 16),
                  Text('Belum Ada Data',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: _slate9,
                      )),
                  const SizedBox(height: 4),
                  Text('Semua pemesananmu akan muncul di sini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: _slate5,
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().refresh(),
      color: _green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i], tab),
      ),
    );
  }

  // ── Kartu Riwayat ─────────────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> item, String tab) {
    final tipe    = item['tipe'] as String? ?? 'Layanan';
    final status  = item['status'] as String? ?? '-';
    final layanan = item['layanan'] as String? ?? '-';
    final tanggal = item['tanggal'] as String? ?? '-';
    final detail  = item['detail'] as String? ?? '-';
    final harga   = item['total_harga'] as int? ?? 0;
    final id      = item['id']?.toString() ?? '-';

    // Warna berdasarkan status
    final Color statusBg;
    final Color statusTxt;
    final Color tipeBg;
    final Color tipeTxt;

    switch (status) {
      case 'Lunas':
      case 'Selesai':
      case 'Terkonfirmasi':
        statusBg  = const Color(0xFFECFDF5);
        statusTxt = _green;
        tipeBg    = const Color(0xFFECFDF5);
        tipeTxt   = _green;
        break;
      case 'Dibatalkan':
        statusBg  = const Color(0xFFFFEBEE);
        statusTxt = Colors.redAccent;
        tipeBg    = const Color(0xFFFFEBEE);
        tipeTxt   = Colors.redAccent;
        break;
      default: // Belum Dibayar / pending
        statusBg  = const Color(0xFFFFF7ED);
        statusTxt = _orange;
        tipeBg    = const Color(0xFFFFF7ED);
        tipeTxt   = _orange;
    }

    // Emoji ikon tipe
    final emoji = {
      'Tiket Masuk': '🎫',
      'Sewa Camp'  : '⛺',
      'Penginapan' : '🏠',
      'Sewa Alat'  : '🎒',
    }[tipe] ?? '🌿';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _slate2),
        boxShadow: [
          BoxShadow(
            color: _slate9.withOpacity(.02),
            blurRadius: 16, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // ── Header kartu ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: tipeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(layanan,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, fontWeight: FontWeight.w800,
                            color: _slate9,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tipeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tipe,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: tipeTxt,
                              )),
                        ),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5, fontWeight: FontWeight.w800,
                        color: statusTxt,
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _slate2),

          // ── Detail transaksi ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12,
            ),
            child: Column(
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: _slate5),
                  const SizedBox(width: 6),
                  Text(tanggal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, color: _slate5,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(width: 16),
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: _slate5),
                  const SizedBox(width: 6),
                  Text(detail,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, color: _slate5,
                        fontWeight: FontWeight.w500,
                      )),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KODE BOOKING',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9, fontWeight: FontWeight.w800,
                              color: _slate5, letterSpacing: 0.6,
                            )),
                        const SizedBox(height: 2),
                        Text(id,
                            style: GoogleFonts.spaceMono(
                              fontSize: 11.5, fontWeight: FontWeight.w700,
                              color: _slate9,
                            )),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TOTAL TAGIHAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9, fontWeight: FontWeight.w800,
                              color: _slate5, letterSpacing: 0.6,
                            )),
                        const SizedBox(height: 2),
                        Text(CurrencyFormatter.format(harga),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: _green,
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action bar (berdasarkan tab) ──
          if (tab == 'pending' || tab == 'active') ...[
            const Divider(height: 1, color: _slate2),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Batalkan (pending saja)
                  if (tab == 'pending') ...[
                    OutlinedButton(
                      onPressed: () => _cancelBooking(item),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                      ),
                      child: Text('Batalkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          )),
                    ),
                    const SizedBox(width: 10),
                    // ✅ Tombol Bayar → PembayaranScreen
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PembayaranScreen(
                            paymentUrl: item['payment_url'] ?? '',
                            kodeBooking: id,
                            totalHarga: harga,
                            layanan: layanan,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                      ),
                      child: Text('Bayar Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ],

                  // Tombol E-Ticket (aktif saja)
                  if (tab == 'active')
                    OutlinedButton.icon(
                      onPressed: () => _showETicket(id, layanan, detail, tanggal),
                      icon: const Icon(Icons.qr_code_rounded,
                          size: 16, color: _green),
                      label: Text('Lihat E-Ticket',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: _green,
                          )),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── E-Ticket modal ────────────────────────────────────────────────────────
  void _showETicket(
    String id, String layanan, String detail, String tanggal,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44, height: 4,
              decoration: BoxDecoration(
                color: _slate2, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('E-Ticket Resmi CitiisGo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _slate9,
                )),
            const SizedBox(height: 4),
            Text('Tunjukkan QR Code ini kepada petugas gerbang masuk',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: _slate5, fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: _slate2, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF8FAFC),
              ),
              child: Column(children: [
                const Icon(Icons.qr_code_2_rounded, size: 130, color: _slate9),
                const SizedBox(height: 12),
                Text(id,
                    style: GoogleFonts.spaceMono(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: _green, letterSpacing: 1.2,
                    )),
                const SizedBox(height: 6),
                Text(layanan,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, fontWeight: FontWeight.w800,
                      color: _slate9,
                    )),
                const SizedBox(height: 4),
                Text('$detail  ·  $tanggal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5, color: _slate5,
                      fontWeight: FontWeight.w600,
                    )),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    color: _orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'E-Ticket ini hanya berlaku satu kali. '
                    'Jangan bagikan QR kepada pihak lain.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5, color: _orange,
                      fontWeight: FontWeight.w600, height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildErrorState(String msg, VoidCallback onRetry) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: _slate2),
            const SizedBox(height: 14),
            Text('Koneksi API Bermasalah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _slate9,
                )),
            const SizedBox(height: 4),
            Text(msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: _slate5,
                )),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
}