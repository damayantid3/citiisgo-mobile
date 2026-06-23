import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/wisata_repository.dart'; // ✅ Repository ke API

// Import Halaman Form Transaksi
import '../tiket/booking_tiket_screen.dart';
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
  // ✅ GANTI: pakai WisataRepository → API nyata
  final _repo = WisataRepository();

  WisataModel? _wisata;
  bool _isLoading = true;
  String? _error;
  bool _isFav = false;
  late TabController _tabCtrl;

  static const _green  = Color(0xFF0F7133);
  static const _orange = Color(0xFFFF7A00);
  static const _slate9 = Color(0xFF0F172A);
  static const _slate5 = Color(0xFF64748B);
  static const _slate2 = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ✅ Load dari API nyata — bukan _dummyMaster lagi
  Future<void> _loadDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final w = await _repo.getDetail(widget.wisataId);
      if (mounted) {
        setState(() {
          _wisata   = w;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error    = 'Gagal memuat detail wisata. Periksa koneksi API.';
          _isLoading = false;
        });
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  String _fmtHarga(int h) {
    if (h >= 1000000) return 'Rp ${(h / 1000000).toStringAsFixed(1)}jt';
    if (h >= 1000)    return 'Rp ${(h / 1000).toStringAsFixed(0)}rb';
    return 'Rp $h';
  }

  String _resolvePhoto(WisataModel w) {
    if (w.cover != null && w.cover!.startsWith('http')) return w.cover!;
    if (w.emoji != null && w.emoji!.startsWith('http')) return w.emoji!;
    // Fallback foto alam Tasikmalaya
    return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'
        '?auto=format&fit=crop&w=800&q=80';
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen, strokeWidth: 3,
          ),
        ),
      );
    }

    if (_error != null || _wisata == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: _green, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.borderColor),
              const SizedBox(height: 16),
              Text(_error ?? 'Data tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: _slate5, fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final w       = _wisata!;
    final fotoUrl = _resolvePhoto(w);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── SliverAppBar: foto dari API ──────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                backgroundColor: _green,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => setState(() => _isFav = !_isFav),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFav ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ✅ Foto dari API (cover field)
                      Image.network(
                        fotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _green.withOpacity(.8),
                          child: const Center(
                            child: Icon(Icons.landscape_rounded,
                                size: 80, color: Colors.white24),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Info overlay bawah
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              _badgePill(
                                w.kategori?.nama ?? 'Wisata',
                                _green,
                              ),
                              const SizedBox(width: 8),
                              _badgePill('Terpopuler', _orange),
                            ]),
                            const SizedBox(height: 10),
                            Text(w.nama,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 24,
                                  fontWeight: FontWeight.w800, letterSpacing: -0.5,
                                )),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(w.alamat,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withOpacity(.8),
                                      fontSize: 12, fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Statistik card ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _slate9.withOpacity(.04),
                        blurRadius: 24, offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(children: [
                    // ✅ Rating dari API
                    _statItem(Icons.star_rounded,
                        w.rating.toStringAsFixed(1), 'Rating', Colors.amber),
                    _vDiv(),
                    // ✅ Ulasan count dari API (jumlahUlasan field)
                    _statItem(Icons.rate_review_rounded,
                        '${w.jumlahUlasan ?? 0}', 'Ulasan', _green),
                    _vDiv(),
                    // ✅ Kuota dari API
                    _statItem(Icons.people_alt_rounded,
                        '${w.kuotaHarian}', 'Kuota/Hari', _orange),
                  ]),
                ),
              ),

              // ── Tab bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelColor: _green,
                      unselectedLabelColor: _slate5,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Info'),
                        Tab(text: 'Fasilitas'),
                        Tab(text: 'Galeri'),
                        Tab(text: 'Ulasan'),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Tab content ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 360,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _tabInfo(w),
                      _tabFasilitas(w),
                      _tabGaleri(w),
                      _tabUlasan(w),
                    ],
                  ),
                ),
              ),

              // ── Layanan section ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih Layanan & Reservasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: _slate9,
                          )),
                      Text(
                        'Silakan pilih salah satu sub-fitur akomodasi di bawah ini:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: _slate5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✅ 1. Tiket — harga dari API (w.hargaTiket)
                      _buildLayananButton(
                        title: 'Beli Tiket Masuk Utama',
                        subtitle: 'E-Tiket masuk individu tanpa antrean loket fisik.',
                        priceInfo:
                            '${CurrencyFormatter.format(w.hargaTiket)} / Orang',
                        icon: Icons.confirmation_number_rounded,
                        btnColor: _green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingTiketScreen(
                              wisataId: w.id,
                              // ✅ hargaTiket dari API
                              hargaTiket: w.hargaTiket,
                            ),
                          ),
                        ),
                      ),

                      // 2. Camping
                      _buildLayananButton(
                        title: 'Booking Area Camping',
                        subtitle:
                            'Sewa kapling slot camping ground & paket tenda puncak.',
                        priceInfo: 'Mulai dari Rp 75.000 / Malam',
                        icon: Icons.holiday_village_rounded,
                        btnColor: _orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingCampingScreen(wisataId: w.id),
                          ),
                        ),
                      ),

                      // 3. Penginapan
                      _buildLayananButton(
                        title: 'Reservasi Kamar Penginapan/Resort',
                        subtitle:
                            'Booking akomodasi villa alam, lodge, & kamar hotel.',
                        priceInfo: 'Mulai dari Rp 350.000 / Malam',
                        icon: Icons.king_bed_rounded,
                        btnColor: AppColors.info,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingPenginapanScreen(wisataId: w.id),
                          ),
                        ),
                      ),

                      // 4. Sewa Alat
                      _buildLayananButton(
                        title: 'Sewa Alat & Logistik Camping',
                        subtitle:
                            'Penyewaan satuan kompor, matras, dome, & sleeping bag.',
                        priceInfo: 'Item lengkap & higienis',
                        icon: Icons.construction_rounded,
                        btnColor: AppColors.purplePrimary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SewaPeralatanScreen(wisataId: w.id),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100), // ruang untuk bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Fixed bottom bar: harga dari API ────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _slate9.withOpacity(.06),
                    blurRadius: 20, offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Harga Mulai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: _slate5,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    // ✅ Harga dari API
                    Text(_fmtHarga(w.hargaTiket),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: _green,
                        )),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 180, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingTiketScreen(
                          wisataId: w.id,
                          hargaTiket: w.hargaTiket, // ✅ dari API
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Pesan Tiket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab: Info ─────────────────────────────────────────────────────────────
  Widget _tabInfo(WisataModel w) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deskripsi Destinasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _slate9,
                )),
            const SizedBox(height: 8),
            // ✅ Deskripsi dari API
            Text(
              w.deskripsi.isNotEmpty
                  ? w.deskripsi
                  : 'Informasi deskripsi mengenai objek daya tarik wisata alam.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: _slate5, height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            _infoRow(Icons.access_time_filled_rounded,
                'Jam Operasional', '07:00 – 17:00 WIB'),
            _infoRow(Icons.confirmation_number_rounded,
                'Ketentuan Tiket', 'Wajib dibawa saat check-in pintu gerbang utama'),
            _infoRow(Icons.people_alt_rounded,
                'Kapasitas Harian', '${w.kuotaHarian} Orang/Hari'),
          ],
        ),
      );

  Widget _infoRow(IconData icon, String key, String val) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(icon, color: _green, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(key,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: _slate5, fontWeight: FontWeight.w600,
                    )),
                Text(val,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: _slate9, fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ]),
      );

  // ── Tab: Fasilitas ───────────────────────────────────────────────────────
  Widget _tabFasilitas(WisataModel w) {
    // ✅ Coba dari API dulu, fallback ke default jika kosong
    final fasilitasApi = w.fasilitas.isNotEmpty
        ? w.fasilitas.map((f) => f.nama).toList()
        : null;

    final defaultFas = fasilitasApi ??
        ['Parkir Area', 'Toilet Bersih', 'Warung Makan', 'Koneksi WiFi',
          'Area Camping', 'Penginapan', 'Sewa Alat', 'Pos P3K'];
    final defaultIcons = [
      Icons.local_parking, Icons.wc, Icons.restaurant, Icons.wifi,
      Icons.landscape_rounded, Icons.hotel, Icons.backpack,
      Icons.medical_services,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12, crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: defaultFas.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _slate2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i < defaultIcons.length ? defaultIcons[i] : Icons.check_circle_outline,
                color: _green, size: 24),
            const SizedBox(height: 6),
            Text(defaultFas[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: _slate9, fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  // ── Tab: Galeri ──────────────────────────────────────────────────────────
  Widget _tabGaleri(WisataModel w) {
    // ✅ Galeri dari API jika ada, fallback placeholder
    final galeriUrls = w.galeri.isNotEmpty
        ? w.galeri.map((g) => g.url).toList()
        : List.generate(6, (_) => '');

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10, crossAxisSpacing: 10,
      ),
      itemCount: galeriUrls.length,
      itemBuilder: (_, i) {
        final url = galeriUrls[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _slate2,
                    child: const Icon(Icons.image_rounded,
                        color: _slate5, size: 24),
                  ),
                )
              : Container(
                  color: _slate2,
                  child: const Icon(Icons.image_rounded,
                      color: _slate5, size: 24),
                ),
        );
      },
    );
  }

  // ── Tab: Ulasan ──────────────────────────────────────────────────────────
  Widget _tabUlasan(WisataModel w) {
    // Placeholder ulasan — bisa diganti dengan data dari API /wisata/{id}/ulasan
    final names   = ['Rian Hidayat', 'Siti Aminah', 'Fajar Shidiq'];
    final komens  = [
      'Suasananya asri banget, cocok buat refreshing keluarga. Fasilitasnya lengkap!',
      'Pemandangan air terjunnya juara, tapi akses jalan tangga harap diperbaiki.',
      'Tempat camping terbaik di Tasikmalaya! Manajemen slotnya rapi banget.',
    ];
    final ratings = [5.0, 4.5, 5.0];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: names.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _slate2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(names[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, fontSize: 13, color: _slate9,
                    )),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(ratings[i].toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 12,
                      )),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Text('"${komens[i]}"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, color: _slate5,
                  fontWeight: FontWeight.w500, height: 1.5,
                )),
          ],
        ),
      ),
    );
  }

  // ── Widget Helpers ────────────────────────────────────────────────────────
  Widget _buildLayananButton({
    required String title,
    required String subtitle,
    required String priceInfo,
    required IconData icon,
    required Color btnColor,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10, offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: btnColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: btnColor, size: 22),
          ),
          title: Text(title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, fontSize: 13,
                color: AppColors.textPrimary,
              )),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.textSecondary, height: 1.2,
                  )),
              const SizedBox(height: 6),
              Text(priceInfo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5, fontWeight: FontWeight.w800, color: btnColor,
                  )),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textMuted),
          onTap: onTap,
        ),
      );

  Widget _statItem(IconData icon, String val, String lbl, Color iconColor) =>
      Expanded(
        child: Column(children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(val,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w800, color: _slate9,
              )),
          Text(lbl,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: _slate5, fontWeight: FontWeight.w500,
              )),
        ]),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 32, color: _slate2);

  Widget _badgePill(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
            )),
      );
}