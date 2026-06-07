import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../providers/wisata_provider.dart';
import '../../../providers/auth_provider.dart';
import '../wisata/wisata_detail_screen.dart';
import '../profil/profil_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import 'widgets/wisata_card.dart';
import 'widgets/kategori_chip.dart';
import 'widgets/banner_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<String> _kategoriList = ['🌿 Semua', '🏔️ Gunung', '🌊 Pantai', '💧 Air Terjun', '🏛️ Budaya'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WisataProvider>().loadWisata();
    });
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1: return _buildJelajahTab();
      case 2: return const RiwayatScreen();
      case 3: return const ProfilScreen();
      default: return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': '🏠', 'label': 'Beranda'},
      {'icon': '🔍', 'label': 'Jelajah'},
      {'icon': '🧾', 'label': 'Riwayat'},
      {'icon': '👤', 'label': 'Profil'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.asMap().entries.map((e) {
              final active = _navIndex == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _navIndex = e.key),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 3),
                      Text(e.value['label']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.primaryGreen : AppColors.textMuted,
                        )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer2<WisataProvider, AuthProvider>(
      builder: (_, wisataP, authP, __) => CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkGreen, AppColors.primaryGreen],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Halo, Wisatawan! 👋',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.white.withOpacity(0.7))),
                          const SizedBox(height: 2),
                          Text(authP.user?.nama ?? 'Mau jelajah ke mana?',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
                        child: Stack(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16))),
                            ),
                            Positioned(top: 7, right: 7,
                              child: Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange, shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.darkGreen, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Text('🔍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Cari tempat wisata...',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                              border: InputBorder.none, isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          width: 32, height: 32, margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                          child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 14))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promo Banner
                  const BannerSlider(),
                  const SizedBox(height: 16),

                  // Layanan
                  _secHeader('Layanan Kami', null),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _serviceItem('🎫', 'Reservasi Tiket', const Color(0xFFE8F5E9)),
                      _serviceItem('⛺', 'Booking Camping', const Color(0xFFFFF3E0)),
                      _serviceItem('🏨', 'Booking\nPenginapan', const Color(0xFFE3F2FD)),
                      _serviceItem('🎒', 'Sewa Peralatan', const Color(0xFFF3E5F5)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  _secHeader('Kategori', null),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _kategoriList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final raw = _kategoriList[i].replaceAll(RegExp(r'[^\w\s]'), '').trim();
                        final label = _kategoriList[i];
                        final mappedKey = i == 0 ? 'Semua' : raw;
                        return KategoriChip(
                          label: label,
                          isActive: wisataP.kategoriAktif == mappedKey,
                          onTap: () => wisataP.setKategori(mappedKey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Destinasi Populer
                  _secHeader('Destinasi Populer', 'Semua →'),
                  const SizedBox(height: 10),
                  wisataP.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                    : SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: wisataP.popularWisata.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => WisataCard(
                            wisata: wisataP.popularWisata[i],
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => WisataDetailScreen(wisataId: wisataP.popularWisata[i].id),
                            )),
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),

                  // Dekat Dari Kamu
                  _secHeader('Dekat Dari Kamu', 'Semua →'),
                  const SizedBox(height: 4),
                  ...wisataP.nearbyWisata.map((w) => _nearbyItem(w)),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secHeader(String title, String? more) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (more != null)
          Text(more, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _serviceItem(String emoji, String label, Color bg) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }

  Widget _nearbyItem(WisataModel w) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderColor, width: 1))),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(11)),
            child: Center(child: Text(w.emoji ?? '', style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.nama, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('📍 ${w.jarakKm?.toStringAsFixed(0)} km — ${w.lokasi}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('⭐ ${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(w.hargaTiket),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJelajahTab() {
    return Consumer<WisataProvider>(
      builder: (_, p, __) => Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
            color: AppColors.primaryGreen,
            child: TextField(
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari wisata, camping, penginapan...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: p.allWisata.length,
              itemBuilder: (_, i) {
                final w = p.allWisata[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(w.emoji ?? '', style: const TextStyle(fontSize: 30))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.nama, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                            Text('📍 ${w.kecamatan}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Text('⭐ ${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              Text(CurrencyFormatter.formatShort(w.hargaTiket),
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                            ]),
                          ],
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}