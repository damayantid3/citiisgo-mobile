import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository_api.dart'; // ✅ pakai yang ke API
import '../../../providers/notifikasi_provider.dart';
import '../pembayaran/pembayaran_screen.dart';

class TiketListScreen extends StatefulWidget {
  const TiketListScreen({super.key});

  @override
  State<TiketListScreen> createState() => _TiketListScreenState();
}

class _TiketListScreenState extends State<TiketListScreen>
    with SingleTickerProviderStateMixin {
  // ✅ Ganti BookingRepository (lokal) → BookingRepositoryApi (ke API)
  final BookingRepositoryApi _bookingRepo = BookingRepositoryApi();
  late TabController _tabController;
  List<Map<String, dynamic>> _allTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ Ambil semua riwayat dari API (tiket + camping + penginapan + alat)
  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    final data = await _bookingRepo.getRiwayatLengkap();
    if (mounted) {
      setState(() {
        _allTickets = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterByStatus(String tabStatus) {
    switch (tabStatus) {
      case 'pending':
        return _allTickets
            .where((t) =>
                t['status'] == 'Belum Dibayar' ||
                t['status'] == 'pending')
            .toList();
      case 'active':
        return _allTickets
            .where((t) =>
                t['status'] == 'Lunas' ||
                t['status'] == 'Terkonfirmasi' ||
                t['status'] == 'confirmed' ||
                t['status'] == 'paid')
            .toList();
      default:
        return _allTickets
            .where((t) =>
                t['status'] == 'Dibatalkan' ||
                t['status'] == 'Selesai' ||
                t['status'] == 'cancelled' ||
                t['status'] == 'completed')
            .toList();
    }
  }

  /// ✅ Batalkan booking via API
  Future<void> _handleCancelTicket(
      String bookingId, String tipe, String layananNama) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Reservasi?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pemesanan $layananNama ini?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, Batalkan',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    // ✅ Kirim pembatalan ke API
    final success = await _bookingRepo.cancelBooking(tipe, int.tryParse(bookingId) ?? 0);

    if (mounted) {
      if (success) {
        // Update notifikasi lokal
        context.read<NotifikasiProvider>().tambahNotifikasi(
              judul: 'Pemesanan Dibatalkan ❌',
              pesan:
                  'Reservasi $layananNama dengan kode $bookingId telah dibatalkan.',
              tipe: 'batal',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reservasi berhasil dibatalkan',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membatalkan. Coba lagi.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _fetchTickets(); // Refresh dari API
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tiket Wisata Saya',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Tiket Aktif'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('pending'),
                _buildTabContent('active'),
                _buildTabContent('history'),
              ],
            ),
    );
  }

  Widget _buildTabContent(String statusTab) {
    final list = _filterByStatus(statusTab);

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchTickets,
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.confirmation_number_rounded,
                    size: 54,
                    color: AppColors.borderColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Data',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Belum ada transaksi untuk status ini.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTickets,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildTicketCard(list[i], statusTab),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> tiket, String statusTab) {
    // Badge warna berdasarkan status tab
    Color badgeColor = AppColors.warningBg;
    Color badgeText = AppColors.warning;
    String statusLabel = 'Menunggu';

    if (statusTab == 'active') {
      badgeColor = AppColors.lightGreen;
      badgeText = AppColors.primaryGreen;
      statusLabel = 'Siap Masuk';
    } else if (statusTab == 'history') {
      if (tiket['status'] == 'Dibatalkan' ||
          tiket['status'] == 'cancelled') {
        badgeColor = AppColors.dangerLight;
        badgeText = AppColors.danger;
        statusLabel = 'Dibatalkan';
      } else {
        badgeColor = const Color(0xFFF1F5F9);
        badgeText = AppColors.textSecondary;
        statusLabel = 'Selesai';
      }
    }

    // Emoji ikon berdasarkan tipe layanan
    final tipeEmoji = {
      'Tiket Masuk': '🎫',
      'Sewa Camp': '⛺',
      'Penginapan': '🏠',
      'Sewa Alat': '🎒',
    };
    final emoji = tipeEmoji[tiket['tipe']] ?? '🌿';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tiket['layanan'] ?? 'Layanan CitiisGo',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tiket['tipe']} · ${_formatDate(tiket['tanggal'] ?? '')}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KODE TRANSAKSI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tiket['id'] ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tiket['detail'] ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(tiket['total_harga'] ?? 0),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tombol aksi
          if (statusTab == 'pending' || statusTab == 'active') ...[
            const Divider(height: 1, color: AppColors.borderColor),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (statusTab == 'pending') ...[
                    TextButton(
                      onPressed: () => _handleCancelTicket(
                        tiket['id'] ?? '',
                        tiket['tipe'] ?? '',
                        tiket['layanan'] ?? 'Layanan',
                      ),
                      child: Text(
                        'Batalkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PembayaranScreen(
                            paymentUrl:
                                'https://app.sandbox.midtrans.com/snap/v2/vtweb/${tiket['id']}',
                            kodeBooking: tiket['id'] ?? 'BOOK-000',
                            totalHarga: tiket['total_harga'] ?? 0,
                            layanan:
                                tiket['layanan'] ?? 'Reservasi Wisata',
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Bayar Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (statusTab == 'active')
                    OutlinedButton.icon(
                      onPressed: () => _showETicketModal(tiket),
                      icon: const Icon(
                        Icons.qr_code_rounded,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      label: Text(
                        'Lihat E-Ticket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  void _showETicketModal(Map<String, dynamic> tiket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'E-Ticket Resmi CitiisGo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Tunjukkan QR Code ini ke petugas loket',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                size: 120,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tiket['id'] ?? '-',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tiket['detail']}  ·  ${tiket['tanggal']}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (!dateStr.contains('-')) return dateStr;
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final months = [
          '',
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        final m = int.tryParse(parts[1]) ?? 1;
        return '${parts[2]} ${months[m]} ${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }
}