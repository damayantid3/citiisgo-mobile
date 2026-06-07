import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/booking_camping_model.dart';
import '../../../data/models/reservasi_model.dart';
import '../../../data/repositories/booking_repository.dart';


class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});
  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _repo = BookingRepository();
  List<ReservasiModel>     _reservasi  = [];
  List<BookingCampingModel> _camping   = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    final r = await _repo.getMyReservasi();
    final c = await _repo.getMyBookingCamping();
    if (mounted) setState(() { _reservasi = r; _camping = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: SafeArea(bottom: false, child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                const Text('📋 Riwayat Booking', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                GestureDetector(
                  onTap: () { setState(() => _loading = true); _loadData(); },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: AppColors.primaryOrange,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: const [Tab(text: '🎫 Tiket'), Tab(text: '⛺ Camping'), Tab(text: '🏨 Penginapan'), Tab(text: '🎒 Sewa')],
            ),
          ])),
        ),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : TabBarView(controller: _tabCtrl, children: [
              _buildReservasiList(),
              _buildCampingList(),
              _buildPenginapanList(),
              _buildSewaList(),
            ]),
        ),
      ]),
    );
  }

  Widget _buildReservasiList() {
    if (_reservasi.isEmpty) return _emptyState('🎫', 'Belum ada reservasi tiket', 'Yuk, pesan tiket wisata pertamamu!');
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _reservasi.length,
        itemBuilder: (_, i) {
          final r = _reservasi[i];
          return _bookingCard(
            icon: '🎫',
            title: r.wisata?.nama ?? 'Wisata',
            subtitle: '📅 ${r.tanggalKunjungan} · 👥 ${r.jumlahTiket} tiket',
            kode: r.kodeBooking,
            total: r.totalHarga,
            status: r.status,
            color: AppColors.primaryGreen,
          );
        },
      ),
    );
  }

  Widget _buildCampingList() {
    if (_camping.isEmpty) {
      // Demo data
      final demo = [
        {'icon':'⛺','title':'Bukit Teletubbies','sub':'08–10 Jun 2025 · Paket Keluarga · 4 tamu','kode':'CGC-A1B2','total':700000,'status':'confirmed'},
        {'icon':'⛺','title':'Curug Cimedang','sub':'15–17 Jun 2025 · Paket Pasangan · 2 tamu','kode':'CGC-C3D4','total':500000,'status':'pending'},
      ];
      return ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: demo.length,
        itemBuilder: (_, i) {
          final d = demo[i];
          return _bookingCard(
            icon: d['icon'] as String, title: d['title'] as String, subtitle: d['sub'] as String,
            kode: d['kode'] as String, total: d['total'] as int, status: d['status'] as String,
            color: AppColors.primaryOrange,
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _camping.length,
        itemBuilder: (_, i) {
          final c = _camping[i];
          return _bookingCard(
            icon: '⛺',
            title: c.paket?.wisata?.nama ?? 'Wisata',
            subtitle: '📅 ${c.tanggalCheckin} – ${c.tanggalCheckout} · ${c.paket?.namaPaket ?? ''} · ${c.jumlahTamu} tamu',
            kode: c.kodeBooking,
            total: c.totalHarga,
            status: c.status,
            color: AppColors.primaryOrange,
          );
        },
      ),
    );
  }

  Widget _buildPenginapanList() {
    final demo = [
      {'icon':'🏨','title':'Cimedang Lodge','sub':'10–12 Jun 2025 · Suite View · 2 tamu','kode':'BGP-001','total':900000,'status':'confirmed'},
      {'icon':'🏨','title':'Situ Gede Resort','sub':'20–22 Jun 2025 · Deluxe Room · 2 tamu','kode':'BGP-002','total':600000,'status':'pending'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: demo.length,
      itemBuilder: (_, i) {
        final d = demo[i];
        return _bookingCard(
          icon: d['icon'] as String, title: d['title'] as String, subtitle: d['sub'] as String,
          kode: d['kode'] as String, total: d['total'] as int, status: d['status'] as String,
          color: const Color(0xFF1565C0),
        );
      },
    );
  }

  Widget _buildSewaList() {
    final demo = [
      {'icon':'🎒','title':'Curug Cimedang','sub':'14–16 Jun 2025 · Tenda + Carrier × 2','kode':'SGS-001','total':170000,'status':'confirmed'},
    ];
    if (demo.isEmpty) return _emptyState('🎒', 'Belum ada sewa peralatan', 'Sewa peralatan camping untuk petualangan lebih seru!');
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: demo.length,
      itemBuilder: (_, i) {
        final d = demo[i];
        return _bookingCard(
          icon: d['icon'] as String, title: d['title'] as String, subtitle: d['sub'] as String,
          kode: d['kode'] as String, total: d['total'] as int, status: d['status'] as String,
          color: const Color(0xFF6A1B9A),
        );
      },
    );
  }

  Widget _bookingCard({
    required String icon, required String title, required String subtitle,
    required String kode, required int total, required String status, required Color color,
  }) {
    final statusData = {
      'pending':   {'label': '⏳ Pending',   'color': AppColors.warning,      'bg': AppColors.warningBg},
      'confirmed': {'label': '✅ Confirmed', 'color': AppColors.primaryGreen,  'bg': AppColors.lightGreen},
      'completed': {'label': '🏁 Selesai',  'color': AppColors.primaryGreen,  'bg': AppColors.lightGreen},
      'cancelled': {'label': '❌ Dibatalkan','color': AppColors.danger,        'bg': AppColors.dangerLight},
    };
    final sd = statusData[status] ?? {'label': status, 'color': AppColors.textMuted, 'bg': AppColors.background};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(.06),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: sd['bg'] as Color, borderRadius: BorderRadius.circular(8)),
              child: Text(sd['label'] as String, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: sd['color'] as Color)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
              child: Text(kode, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'monospace')),
            ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Rp ${_fmt(total)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            ]),
            const SizedBox(width: 10),
            if (status == 'pending')
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
                  child: const Text('Bayar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              )
            else
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(9)),
                  child: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _emptyState(String icon, String title, String subtitle) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: const TextStyle(fontSize: 60)),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]),
  );

  String _fmt(int h) {
    if (h >= 1000000) return '${(h / 1e6).toStringAsFixed(1)}jt';
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}