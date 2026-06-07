import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../reservasi/reservasi_screen.dart';
import '../camping/booking_camping_screen.dart';
import '../penginapan/booking_penginapan_screen.dart';
import '../peralatan/sewa_peralatan_screen.dart';

class WisataDetailScreen extends StatefulWidget {
  final int wisataId;
  const WisataDetailScreen({super.key, required this.wisataId});
  @override
  State<WisataDetailScreen> createState() => _WisataDetailScreenState();
}

class _WisataDetailScreenState extends State<WisataDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = WisataRepository();
  WisataModel? _wisata;
  bool _loading = true;
  late TabController _tabCtrl;
  int _selectedGaleri = 0;
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadDetail() async {
    final w = await _repo.getDetail(widget.wisataId);
    if (mounted) setState(() { _wisata = w; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : _wisata == null
          ? _errorState()
          : _buildContent(),
    );
  }

  Widget _errorState() => Scaffold(
    appBar: AppBar(backgroundColor: AppColors.primaryGreen),
    body: const Center(child: Text('Wisata tidak ditemukan')),
  );

  Widget _buildContent() {
    final w = _wisata!;
    return CustomScrollView(
      slivers: [
        // ── Hero Image ──
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primaryGreen,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => setState(() => _isFav = !_isFav),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.3), shape: BoxShape.circle),
                child: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFav ? Colors.red : Colors.white, size: 20),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.3), shape: BoxShape.circle),
                child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                  child: Center(child: Text(
                    w.kategori?.ikon ?? '🏔️',
                    style: const TextStyle(fontSize: 80),
                  )),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(.5)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Info overlay
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(w.kategori?.nama ?? 'Wisata',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Populer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(w.nama, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, shadows: [Shadow(blurRadius: 8)])),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 3),
                        Text(w.alamat, style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              // ── Stats row ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    _statItem('⭐', '${w.rating}', 'Rating'),
                    _vDivider(),
                    _statItem('📝', '128', 'Ulasan'),
                    _vDivider(),
                    _statItem('👥', '${w.kuotaHarian}', 'Kuota/hari'),
                    _vDivider(),
                    _statItem('🎫', _formatHarga(w.hargaTiket), 'Tiket'),
                  ],
                ),
              ),

              // ── Tab Bar ──
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabCtrl,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primaryGreen,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: '📋 Info'),
                    Tab(text: '🏕️ Fasilitas'),
                    Tab(text: '📸 Galeri'),
                    Tab(text: '⭐ Ulasan'),
                  ],
                ),
              ),

              // ── Tab Content ──
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _infoTab(w),
                    _fasilitasTab(w),
                    _galeriTab(w),
                    _ulasanTab(),
                  ],
                ),
              ),

              // ── Layanan tersedia ──
              _layananSection(w),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(String ico, String val, String lbl) => Expanded(
    child: Column(
      children: [
        Text(ico, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    ),
  );

  Widget _vDivider() => Container(width: 1, height: 36, color: AppColors.borderColor);

  Widget _infoTab(WisataModel w) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tentang Wisata Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(w.deskripsi, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65)),
        const SizedBox(height: 16),
        _infoRow('📍', 'Alamat', w.alamat),
        _infoRow('⏰', 'Jam Buka', '07:00 – 17:00 WIB'),
        _infoRow('🎫', 'Harga Tiket', _formatHarga(w.hargaTiket) + ' / orang'),
        _infoRow('👥', 'Kuota Harian', '${w.kuotaHarian} orang'),
        if (w.latitude != null) _infoRow('🗺️', 'Koordinat', '${w.latitude}, ${w.longitude}'),
      ],
    ),
  );

  Widget _infoRow(String ico, String key, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ico, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            Text(val, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ],
        )),
      ],
    ),
  );

  Widget _fasilitasTab(WisataModel w) {
    final defaultFas = ['🅿️ Parkir','🚻 Toilet','🍴 Warung Makan','📶 WiFi','🏕️ Area Camping','🏨 Penginapan','🎒 Sewa Alat','🚑 P3K'];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.1),
      itemCount: w.fasilitas.isNotEmpty ? w.fasilitas.length : defaultFas.length,
      itemBuilder: (_, i) {
        final f = w.fasilitas.isNotEmpty ? w.fasilitas[i] : null;
        final txt = f != null ? '${f.ikon ?? '✅'} ${f.nama}' : defaultFas[i];
        final parts = txt.split(' ');
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(parts[0], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(parts.skip(1).join(' '), textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _galeriTab(WisataModel w) {
    final emos = ['🏔️','💧','🌿','🌅','🏕️','🌊'];
    final count = w.galeri.isNotEmpty ? w.galeri.length : emos.length;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: count,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => setState(() => _selectedGaleri = i),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _selectedGaleri == i ? AppColors.primaryGreen : Colors.transparent,
              width: 2),
            color: AppColors.lightGreen,
          ),
          child: Center(child: Text(
            w.galeri.isNotEmpty ? '📷' : emos[i % emos.length],
            style: const TextStyle(fontSize: 30))),
        ),
      ),
    );
  }

  Widget _ulasanTab() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, i) {
      final names = ['Budi S.','Siti R.','Ahmad F.','Dewi K.','Rudi W.'];
      final ratings = [5.0, 4.0, 5.0, 4.5, 5.0];
      final komens = [
        'Tempatnya sangat indah dan bersih! Pengelola sangat ramah dan responsif.',
        'Pemandangan luar biasa! Tapi parkir perlu diperluas karena cukup ramai.',
        'Camping di sini pengalaman tak terlupakan. Pasti balik lagi!',
        'Fasilitas oke, air terjunnya keren banget. Highly recommended!',
        'Worth it banget datang ke sini. Alam asri, udara segar, harga terjangkau.',
      ];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.lightGreen,
                    child: Text(names[i][0], style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Text(names[i], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                  const SizedBox(width: 2),
                  Text('${ratings[i]}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Text('"${komens[i]}"', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.55)),
            const SizedBox(height: 6),
            Text('${i+3} hari lalu', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
      );
    },
  );

  Widget _layananSection(WisataModel w) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Layanan Tersedia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10, crossAxisSpacing: 10,
          childAspectRatio: 2.8,
          children: [
            _layananTile('🎫', 'Reservasi Tiket', _formatHarga(w.hargaTiket)+'/org', AppColors.primaryGreen,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReservasiScreen(wisata: w)))),
            _layananTile('⛺', 'Booking Camping', 'Ab. Rp 120rb/malam', AppColors.primaryOrange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCampingScreen(wisataId: w.id)))),
            _layananTile('🏨', 'Booking Penginapan', 'Ab. Rp 200rb/malam', AppColors.infoColor,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPenginapanScreen(wisataId: w.id)))),
            _layananTile('🎒', 'Sewa Peralatan', 'Ab. Rp 10rb/hari', AppColors.purpleAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => SewaPeralatanScreen(wisataId: w.id)))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ReservasiScreen(wisata: w))),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('🎫 Pesan Tiket Sekarang',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    ),
  );

  Widget _layananTile(String ico, String title, String price, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Row(
          children: [
            Text(ico, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                Text(price, style: TextStyle(fontSize: 10.5, color: color.withOpacity(.7))),
              ],
            )),
          ],
        ),
      ),
    );

  String _formatHarga(int harga) {
    if (harga >= 1000000) return 'Rp ${(harga/1000000).toStringAsFixed(1)}jt';
    if (harga >= 1000) return 'Rp ${(harga/1000).toStringAsFixed(0)}rb';
    return 'Rp $harga';
  }
}

// ── Color extensions ──
extension ColorExt on AppColors {
  static Color get infoColor => const Color(0xFF1565C0);
  static Color get purpleAccent => const Color(0xFF6A1B9A);
}