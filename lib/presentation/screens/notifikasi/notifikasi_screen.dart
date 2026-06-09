import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../providers/notifikasi_provider.dart'; // Import Provider Pusat

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // 1. HEADER UTAMA DENGAN BUTTON BACK & BUTTON TANDAI DIBACA
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context), // Kembali ke Beranda Utama
        ),
        title: Text(
          'Notifikasi Aktivitas',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          // Tombol muncul otomatis jika ada pesan yang belum dibaca
          Consumer<NotifikasiProvider>(
            builder: (context, notifP, _) {
              final adaUnread = notifP.listNotifikasi.any((n) => !n.isRead);
              if (!adaUnread) return const SizedBox();
              return TextButton(
                onPressed: () => notifP.tandaiSemuaDibaca(),
                child: Text(
                  'Tandai Dibaca',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
      
      // 2. BODY UTAMA MENGGUNAKAN CONSUMER UNTUK MENDENGARKAN REALTIME STATE
      body: Consumer<NotifikasiProvider>(
        builder: (context, notifP, child) {
          final listNotif = notifP.listNotifikasi;

          // Jika tidak ada aktivitas pemesanan atau promo
          if (listNotif.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_off_rounded, size: 32, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi baru',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aktivitas pemesanan & promo akan muncul di sini.',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          // Render list notifikasi yang diambil dari NotifikasiProvider terpusat
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: listNotif.length,
            itemBuilder: (context, index) {
              final notif = listNotif[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  // Jika belum dibaca (isRead = false), warnanya akan hijau muda transparan transisi cerah
                  color: notif.isRead ? AppColors.white : AppColors.lightGreen.withOpacity(0.25),
                  border: const Border(bottom: BorderSide(color: AppColors.borderColor, width: 0.6)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(notif.tipe),
                    radius: 22,
                    child: Icon(_getIconData(notif.tipe), color: Colors.white, size: 18),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        notif.waktu,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      notif.pesan,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ),
                  onTap: () {
                    // Ketika item diklik, otomatis status berubah jadi "Read" (Warna memudar jadi putih)
                    notifP.tandaiSatuDibaca(notif.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getIconColor(String tipe) {
    switch (tipe) {
      case 'sukses':
        return AppColors.primaryGreen; // Ikon lingkaran Hijau untuk sukses booking
      case 'batal':
        return AppColors.danger; // Ikon lingkaran Merah untuk pembatalan transaksi
      case 'paket':
        return AppColors.primaryOrange; // Ikon lingkaran Orange untuk info paket/sewa
      case 'promo':
      default:
        return Colors.blue.withOpacity(0.8); // Promo / Info Umum
    }
  }

  IconData _getIconData(String tipe) {
    switch (tipe) {
      case 'sukses':
        return Icons.check_circle_rounded;
      case 'batal':
        return Icons.cancel_rounded;
      case 'paket':
        return Icons.backpack_rounded;
      case 'promo':
      default:
        return Icons.local_offer_rounded;
    }
  }
}