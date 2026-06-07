import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/notifikasi_model.dart';
import '../../../data/repositories/booking_repository.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});
  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _repo = BookingRepository();
  List<NotifikasiModel> _notifs = [];
  bool _loading = true;

  // Demo data jika API belum tersedia
  final List<Map<String, dynamic>> _demoNotifs = [
    {
      'id': 1, 'judul': '✅ Pembayaran Berhasil!',
      'pesan': 'Reservasi tiket Curug Cimedang (CG-3021) telah dikonfirmasi. Selamat berwisata!',
      'tipe': 'success', 'is_read': false, 'created_at': '2 menit lalu'
    },
    {
      'id': 2, 'judul': '⛺ Booking Camping Dikonfirmasi',
      'pesan': 'Booking camping Bukit Teletubbies (CGC-A1B2) paket Keluarga Premium telah dikonfirmasi oleh pengelola.',
      'tipe': 'booking', 'is_read': false, 'created_at': '1 jam lalu'
    },
    {
      'id': 3, 'judul': '🎉 Promo Spesial Weekend!',
      'pesan': 'Dapatkan diskon 30% untuk tiket masuk semua wisata alam setiap Sabtu-Minggu bulan ini. Gunakan kode: WEEKEND30',
      'tipe': 'info', 'is_read': false, 'created_at': '3 jam lalu'
    },
    {
      'id': 4, 'judul': '⏰ Pengingat Kunjungan',
      'pesan': 'Besok Anda memiliki jadwal kunjungan ke Pantai Sindangkerta. Jangan lupa persiapkan perlengkapan Anda!',
      'tipe': 'warning', 'is_read': true, 'created_at': '1 hari lalu'
    },
    {
      'id': 5, 'judul': '⭐ Berikan Ulasan Anda',
      'pesan': 'Bagaimana pengalaman Anda di Situ Gede? Berikan ulasan dan bantu wisatawan lain menemukan destinasi terbaik.',
      'tipe': 'info', 'is_read': true, 'created_at': '2 hari lalu'
    },
    {
      'id': 6, 'judul': '🎒 Sewa Peralatan Siap',
      'pesan': 'Peralatan camping Anda (SGS-001) telah disiapkan. Silakan ambil di lokasi wisata saat tiba.',
      'tipe': 'success', 'is_read': true, 'created_at': '3 hari lalu'
    },
    {
      'id': 7, 'judul': '🏨 Kamar Tersedia',
      'pesan': 'Kamar Suite View Air Terjun di Cimedang Lodge kini tersedia untuk tanggal pilihan Anda. Segera booking!',
      'tipe': 'info', 'is_read': true, 'created_at': '5 hari lalu'
    },
    {
      'id': 8, 'judul': '💳 Pembayaran Menunggu',
      'pesan': 'Booking camping Anda (CGC-C3D4) belum dibayar. Selesaikan pembayaran sebelum batas waktu: 23:59 hari ini.',
      'tipe': 'warning', 'is_read': true, 'created_at': '1 minggu lalu'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markAllRead() async {
    setState(() {
      for (var n in _demoNotifs) n['is_read'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Semua notifikasi ditandai sudah dibaca'),
      backgroundColor: AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _markOneRead(int id) {
    setState(() {
      final idx = _demoNotifs.indexWhere((n) => n['id'] == id);
      if (idx != -1) _demoNotifs[idx]['is_read'] = true;
    });
  }

  int get _unreadCount => _demoNotifs.where((n) => !(n['is_read'] as bool)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🔔 Notifikasi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('Pemberitahuan terbaru untuk Anda', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              if (_unreadCount > 0) GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.done_all_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 5),
                    const Text('Tandai semua', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          )),
        ),

        // Unread badge
        if (_unreadCount > 0) Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.lightOrange, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('$_unreadCount notifikasi belum dibaca', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
              ]),
            ),
          ]),
        ),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryGreen,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                itemCount: _demoNotifs.length,
                itemBuilder: (_, i) => _notifCard(_demoNotifs[i]),
              ),
            ),
        ),
      ]),
    );
  }

  Widget _notifCard(Map<String, dynamic> n) {
    final isRead   = n['is_read'] as bool;
    final tipe     = n['tipe'] as String;

    final tipeConfig = {
      'success': {'color': AppColors.primaryGreen,  'bg': AppColors.lightGreen,   'icon': '✅'},
      'booking': {'color': AppColors.primaryGreen,  'bg': AppColors.lightGreen,   'icon': '🎫'},
      'warning': {'color': AppColors.warning,       'bg': AppColors.warningBg,    'icon': '⚠️'},
      'info':    {'color': const Color(0xFF1565C0), 'bg': const Color(0xFFE3F2FD),'icon': 'ℹ️'},
      'danger':  {'color': AppColors.danger,        'bg': AppColors.dangerLight,  'icon': '❌'},
    };
    final cfg = tipeConfig[tipe] ?? tipeConfig['info']!;

    return GestureDetector(
      onTap: () => _markOneRead(n['id'] as int),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : (cfg['bg'] as Color).withOpacity(.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? AppColors.borderColor : (cfg['color'] as Color).withOpacity(.25),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead ? [] : [BoxShadow(color: (cfg['color'] as Color).withOpacity(.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left color bar
          Container(
            width: 4,
            height: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: isRead ? Colors.transparent : cfg['color'] as Color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          // Icon
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cfg['bg'] as Color, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(cfg['icon'] as String, style: const TextStyle(fontSize: 18))),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(n['judul'] as String,
                      style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, color: AppColors.textPrimary)),
                  ),
                  if (!isRead) Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                  ),
                ]),
                const SizedBox(height: 5),
                Text(n['pesan'] as String,
                  style: TextStyle(fontSize: 12.5, color: isRead ? AppColors.textMuted : AppColors.textSecondary, height: 1.5),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(n['created_at'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const Spacer(),
                  if (!isRead) Text('Ketuk untuk baca', style: TextStyle(fontSize: 10.5, color: (cfg['color'] as Color).withOpacity(.7), fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}