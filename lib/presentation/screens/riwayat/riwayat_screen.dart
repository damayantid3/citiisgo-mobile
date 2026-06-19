import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/booking_repository.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final _bookingRepo = BookingRepository();
  late Future<List<Map<String, dynamic>>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _bookingRepo.getRiwayatFromApi();
  }

  Future<void> _refresh() async {
    setState(() {
      _riwayatFuture = _bookingRepo.getRiwayatFromApi();
    });
    await _riwayatFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Riwayat Pemesanan',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _riwayatFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen, strokeWidth: 3));
            }

            final listRiwayat = snapshot.data ?? [];

            if (listRiwayat.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📅', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('Belum Ada Transaksi',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(
                              'Semua pemesanan tiket dan logistikmu akan muncul di sini.',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: AppColors.textSecondary),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: listRiwayat.length,
              itemBuilder: (context, idx) {
                final item = listRiwayat[idx];
                final isLunas = item['status'] == 'Lunas';
                final isCancelled = item['status'] == 'Dibatalkan';

                final Color badgeBg = isLunas
                    ? const Color(0xFFECFDF5)
                    : isCancelled
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFF7ED);
                final Color badgeFg = isLunas
                    ? AppColors.primaryGreen
                    : isCancelled
                        ? AppColors.danger
                        : AppColors.primaryOrange;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(item['tipe'],
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: badgeFg)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: badgeFg,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(item['status'],
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.borderColor),
                      Row(
                        children: [
                          Expanded(
                              child: Text(item['layanan'],
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          Text(item['id'],
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(item['tanggal'],
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500))),
                          const SizedBox(width: 14),
                          const Icon(Icons.confirmation_num_outlined,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(item['detail'],
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                          Text(CurrencyFormatter.format(item['total_harga']),
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
