import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_state_widget.dart';
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

  static const colorPrimary  = Color(0xFF0F7133);
  static const colorOrange   = Color(0xFFFF7A00);
  static const colorSlate900 = Color(0xFF0F172A);
  static const colorSlate500 = Color(0xFF64748B);
  static const colorSlate200 = Color(0xFFE2E8F0);

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: colorPrimary, strokeWidth: 3))
        : _wisata == null
          ? _errorState()
          : _buildContent(),
    );
  }

  Widget _errorState() => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: colorSlate900, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: ErrorStateWidget(
      title: 'Destinasi Tidak Ditemukan',
      message: 'Gagal mengambil detail destinasi wisata. Silakan periksa koneksi internet Anda.',
      onRetry: () {
        setState(() {
          _loading = true;
        });
        _loadDetail();
      },
    ),
  );

  Widget _buildContent() {
    final w = _wisata!;
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Image Area dengan Efek Blur Overlay Halus
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              elevation: 0,
              backgroundColor: colorPrimary,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(.35), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => setState(() => _isFav = !_isFav),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(.35), shape: BoxShape.circle),
                    child: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFav ? Colors.redAccent : Colors.white, size: 20),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF064E3B), colorPrimary], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                      ),
                      child: w.localAssetPath != null
                          ? Image.asset(w.localAssetPath!, fit: BoxFit.cover)
                          : (w.cover != null && w.cover!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: w.cover!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const ShimmerPlaceholder(width: double.infinity, height: 300, borderRadius: 0),
                                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.landscape_rounded, size: 80, color: Colors.white24)),
                                )
                              : const Center(child: Icon(Icons.landscape_rounded, size: 80, color: Colors.white24)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(.65)],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(8)),
                              child: Text(w.kategori?.nama ?? 'Wisata', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: colorOrange, borderRadius: BorderRadius.circular(8)),
                              child: Text('Terpopuler', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          Text(w.nama, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Expanded(child: Text(w.alamat, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(.8), fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                  // Row Panel Statistik Premium ala Card Mengambang
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))]
                    ),
                    child: Row(
                      children: [
                        _statItem(Icons.star_rounded, '${w.rating}', 'Rating', Colors.amber),
                        _vDivider(),
                        _statItem(Icons.rate_review_rounded, '128', 'Ulasan', colorPrimary),
                        _vDivider(),
                        _statItem(Icons.people_alt_rounded, '${w.kuotaHarian}', 'Kuota/Hari', colorOrange),
                      ],
                    ),
                  ),

                  // Tab Bar Bergaya Segmented Control Tailwind
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelColor: colorPrimary,
                      unselectedLabelColor: colorSlate500,
                      indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800),
                      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Info'), Tab(text: 'Fasilitas'), Tab(text: 'Galeri'), Tab(text: 'Ulasan'),
                      ],
                    ),
                  ),

                  // Konten Kontainer Dinamis TabView
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _infoTab(w), _fasilitasTab(w), _galeriTab(w), _ulasanTab(),
                      ],
                    ),
                  ),

                  _layananSection(w),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
        
        // Tombol Checkout Utama yang Fixed/Mengambang Selamanya di bawah Layar
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))]
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Harga Mulai', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: colorSlate500, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_formatHarga(w.hargaTiket), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: colorPrimary)),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 180, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReservasiScreen(wisata: w))),
                    style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: Text('Pesan Tiket', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _statItem(IconData icon, String val, String lbl, Color iconColor) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: colorSlate900)),
        Text(lbl, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: colorSlate500, fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _vDivider() => Container(width: 1, height: 32, color: colorSlate200);

  Widget _infoTab(WisataModel w) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deskripsi Destinasi', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: colorSlate900)),
        const SizedBox(height: 8),
        Text(w.deskripsi, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: colorSlate500, height: 1.6, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        _infoRow(Icons.access_time_filled_rounded, 'Jam Operasional', '07:00 – 17:00 WIB'),
        _infoRow(Icons.confirmation_number_rounded, 'Ketentuan Tiket', 'Wajib dibawa saat check-in pintu gerbang utama'),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String key, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: colorPrimary, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: colorSlate500, fontWeight: FontWeight.w600)),
            Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: colorSlate900, fontWeight: FontWeight.w700)),
          ],
        )),
      ],
    ),
  );

  Widget _fasilitasTab(WisataModel w) {
    final defaultFas = ['Parkir Area','Toilet Bersih','Warung Makan','Koneksi WiFi','Area Camping','Penginapan','Sewa Alat','Pos P3K'];
    final defaultIcons = [Icons.local_parking, Icons.wc, Icons.restaurant, Icons.wifi, Icons.landscape_rounded, Icons.hotel, Icons.backpack, Icons.medical_services];
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
      itemCount: defaultFas.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorSlate200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(defaultIcons[i], color: colorPrimary, size: 24),
            const SizedBox(height: 6),
            Text(defaultFas[i], textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: colorSlate900, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _galeriTab(WisataModel w) {
    final list = w.galeri;
    if (list.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: 6,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(14)),
          child: const Center(child: Icon(Icons.image_rounded, color: colorSlate500, size: 24)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final img = list[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: img.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ShimmerPlaceholder(width: double.infinity, height: double.infinity, borderRadius: 14),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFE2E8F0),
              child: const Icon(Icons.broken_image_rounded, color: colorSlate500, size: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _ulasanTab() => ListView.builder(
    padding: const EdgeInsets.all(20),
    physics: const BouncingScrollPhysics(),
    itemCount: 3,
    itemBuilder: (_, i) {
      final names = ['Rian Hidayat','Siti Aminah','Fajar Shidiq'];
      final komens = ['Suasananya asri banget, cocok buat refreshing keluarga. Fasilitasnya lengkap!', 'Pemandangan air terjunnya juara, tapi akses jalan tangga harap diperbaiki.', 'Tempat camping terbaik di Tasikmalaya! Manajemen slotnya rapi banget.'];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: colorSlate200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(names[i], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: colorSlate900)),
                Row(children: const [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  SizedBox(width: 2),
                  Text('5.0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Text('"${komens[i]}"', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: colorSlate500, fontWeight: FontWeight.w500, height: 1.5)),
          ],
        ),
      );
    },
  );

  Widget _layananSection(WisataModel w) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Layanan Terintegrasi', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: colorSlate900)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _layananTile(
              Icons.confirmation_number_rounded,
              'Tiket Masuk',
              _formatHarga(w.hargaTiket),
              colorPrimary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReservasiScreen(wisata: w))),
            ),
            _layananTile(
              Icons.nature_rounded,
              'Sewa Camping',
              'Mulai 120rb',
              colorOrange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCampingScreen(wisataId: w.id))),
            ),
            _layananTile(
              Icons.hotel_rounded,
              'Penginapan',
              'Mulai 200rb',
              const Color(0xFF1565C0),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPenginapanScreen(wisataId: w.id))),
            ),
            _layananTile(
              Icons.backpack_rounded,
              'Peralatan Alpin',
              'Mulai 10rb',
              const Color(0xFF6A1B9A),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => SewaPeralatanScreen(wisataId: w.id))),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _layananTile(IconData icon, String title, String price, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(.15))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: color), maxLines: 1),
              Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color.withOpacity(.8), fontWeight: FontWeight.w600)),
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