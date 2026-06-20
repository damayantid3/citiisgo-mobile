import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../providers/notifikasi_provider.dart'; // Import provider notifikasi dinamis
import '../pembayaran/pembayaran_screen.dart';

class TiketListScreen extends StatefulWidget {
  final bool showOnlyCompleted;
  const TiketListScreen({super.key, this.showOnlyCompleted = false});

  @override
  State<TiketListScreen> createState() => _TiketListScreenState();
}

class _TiketListScreenState extends State<TiketListScreen>
    with SingleTickerProviderStateMixin {
  final BookingRepository _bookingRepo = BookingRepository();
  TabController? _tabController;
  List<Map<String, dynamic>> _allTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.showOnlyCompleted) {
      _tabController = TabController(length: 3, vsync: this);
    }
    _fetchTickets();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);

    final data = await _bookingRepo.getRiwayatFromApi();

    if (mounted) {
      setState(() {
        _allTickets = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterByStatus(String tabStatus) {
    if (tabStatus == 'pending') {
      return _allTickets.where((t) => t['status'] == 'Belum Dibayar').toList();
    } else if (tabStatus == 'active') {
      return _allTickets.where((t) => t['status'] == 'Lunas').toList();
    } else if (tabStatus == 'completed_only') {
      return _allTickets.where((t) => t['status'] == 'Selesai').toList();
    } else {
      return _allTickets
          .where((t) => t['status'] == 'Dibatalkan' || t['status'] == 'Selesai')
          .toList();
    }
  }

  Future<void> _handleCancelTicket(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Batalkan Reservasi?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary)),
        content: Text(
            'Apakah Anda yakin ingin membatalkan pemesanan tiket masuk pariwisata ini?',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style:
                      GoogleFonts.plusJakartaSans(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya, Batalkan',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.danger, fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final idx =
          _allTickets.indexWhere((element) => element['id'] == bookingId);
      if (idx == -1) {
        setState(() => _isLoading = false);
        return;
      }

      final layananNama = _allTickets[idx]['layanan'] ?? 'Layanan Wisata';
      final tipeRaw = _allTickets[idx]['tipe_raw'] as String;
      final numericId = _allTickets[idx]['numeric_id'] as int;

      final res = await _bookingRepo.cancelBooking(tipeRaw, numericId);

      if (!mounted) return;

      if (res['success'] == true) {
        context.read<NotifikasiProvider>().tambahNotifikasi(
              judul: 'Pemesanan Dibatalkan ❌',
              pesan:
                  'Reservasi $layananNama dengan Kode Transaksi $bookingId telah berhasil dibatalkan.',
              tipe: 'batal',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservasi berhasil dibatalkan',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal membatalkan reservasi',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      await _fetchTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOnlyCompleted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Riwayat Transaksi Selesai',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen, strokeWidth: 3))
            : _buildTicketListContent('completed_only'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tiket Wisata Saya',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Tiket Aktif'),
            Tab(text: 'Riwayat Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryGreen, strokeWidth: 3))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTicketListContent('pending'),
                _buildTicketListContent('active'),
                _buildTicketListContent('history'),
              ],
            ),
    );
  }

  Widget _buildTicketListContent(String statusTab) {
    final filteredList = _filterByStatus(statusTab);

    if (filteredList.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _fetchTickets(),
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_number_rounded,
                    size: 54, color: AppColors.borderColor),
                const SizedBox(height: 16),
                Text('Tidak Ada Data Tiket',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                    'Belum ada manifes transaksi tiket masuk untuk kategori status ini.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchTickets(),
      color: AppColors.primaryGreen,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          return _buildTicketCardItem(item, statusTab);
        },
      ),
    );
  }

  Widget _buildTicketCardItem(Map<String, dynamic> tiket, String statusTab) {
    Color badgeColor = AppColors.warningBg;
    Color badgeTextColor = AppColors.warning;
    String statusLabel = 'Menunggu';

    if (statusTab == 'active') {
      badgeColor = AppColors.lightGreen;
      badgeTextColor = AppColors.primaryGreen;
      statusLabel = 'Siap Masuk';
    } else if (statusTab == 'history') {
      if (tiket['status'] == 'Dibatalkan') {
        badgeColor = AppColors.dangerLight;
        badgeTextColor = AppColors.danger;
        statusLabel = 'Dibatalkan';
      } else {
        badgeColor = const Color(0xFFF1F5F9);
        badgeTextColor = AppColors.textSecondary;
        statusLabel = 'Selesai';
      }
    } else if (statusTab == 'completed_only') {
      badgeColor = const Color(0xFFF1F5F9);
      badgeTextColor = AppColors.textSecondary;
      statusLabel = 'Selesai';
    }

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
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text('🌋', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tiket['layanan'] ?? 'Layanan CitiisGo',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Sesi: ${_formatInputDate(tiket['tanggal'] ?? '')}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badgeTextColor)),
                )
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
                    Text('KODE TRANSAKSI',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(tiket['id'] ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(tiket['detail'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(CurrencyFormatter.format(tiket['total_harga'] ?? 0),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen)),
                  ],
                )
              ],
            ),
          ),
          if (statusTab == 'pending' || statusTab == 'active') ...[
            const Divider(height: 1, color: AppColors.borderColor),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (statusTab == 'pending') ...[
                    TextButton(
                      onPressed: () => _handleCancelTicket(tiket['id'] ?? ''),
                      child: Text('Batalkan',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final paid = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PembayaranScreen(
                                      paymentUrl: tiket['payment_url'] ?? '',
                                      kodeBooking: tiket['id'] ?? 'TKT-000',
                                      totalHarga: tiket['total_harga'] ?? 0,
                                      layanan: tiket['layanan'] ??
                                          'Reservasi Wisata',
                                      isFromHistory: true,
                                    )));
                        if (mounted) {
                          await _fetchTickets();
                          if (paid == true) {
                            _tabController?.animateTo(1);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0),
                      child: Text('Bayar Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    )
                  ],
                  if (statusTab == 'active') ...[
                    OutlinedButton.icon(
                      onPressed: () => _showTicketBarcodeModal(tiket),
                      icon: const Icon(Icons.qr_code_rounded,
                          size: 16, color: AppColors.primaryGreen),
                      label: Text('Lihat E-Ticket',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleCompleteTicket(tiket),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0),
                      child: Text(
                          tiket['tipe_raw'] == 'sewa_peralatan'
                              ? 'Kembalikan Alat'
                              : 'Gunakan Tiket',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ],
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  void _showTicketBarcodeModal(Map<String, dynamic> tiket) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('E-Ticket Masuk Resmi',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text('Tunjukkan QR Code ini kepada petugas loket',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.qr_code_rounded,
                  size: 120, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(tiket['id'] ?? '-',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    letterSpacing: 1)),
            const SizedBox(height: 4),
            Text('${tiket['detail']}  ·  ${tiket['tanggal']}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCompleteTicket(Map<String, dynamic> tiket) async {
    final tipeRaw = tiket['tipe_raw'] as String;
    final numericId = tiket['numeric_id'] as int;
    final label = tipeRaw == 'sewa_peralatan' ? 'pengembalian peralatan' : 'penggunaan tiket';
    final actionName = tipeRaw == 'sewa_peralatan' ? 'Kembalikan' : 'Gunakan';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$actionName Reservasi?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary)),
        content: Text(
            'Apakah Anda yakin ingin menandai $label ini sebagai selesai? Tindakan ini akan memulihkan kuota/stok terkait.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style:
                      GoogleFonts.plusJakartaSans(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya, Selesaikan',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryGreen, fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final res = await _bookingRepo.completeBooking(tipeRaw, numericId);

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pemesanan berhasil diselesaikan.',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal memproses status.',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      await _fetchTickets();
    }
  }

  String _formatInputDate(String dateStr) {
    try {
      if (dateStr.contains(' s/d ')) {
        final dates = dateStr.split(' s/d ');
        if (dates.length == 2) {
          return '${_formatSingleDate(dates[0])} s/d ${_formatSingleDate(dates[1])}';
        }
      }
      return _formatSingleDate(dateStr);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatSingleDate(String dateStr) {
    try {
      var cleanDate = dateStr.trim();
      if (cleanDate.contains('T')) {
        cleanDate = cleanDate.split('T')[0];
      }
      if (cleanDate.contains(' ')) {
        cleanDate = cleanDate.split(' ')[0];
      }
      if (!cleanDate.contains('-')) return cleanDate;
      final parts = cleanDate.split('-');
      if (parts.length == 3) {
        final bln = [
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
        ][int.parse(parts[1])];
        return '${parts[2]} $bln ${parts[0]}';
      }
      return cleanDate;
    } catch (_) {
      return dateStr;
    }
  }
}
