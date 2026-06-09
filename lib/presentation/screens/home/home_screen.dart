import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../providers/wisata_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notifikasi_provider.dart'; // IMPORT PROVIDER NOTIFIKASI

// Jalur Impor Halaman Fitur Valid
import '../wisata/wisata_detail_screen.dart';
import '../reservasi/reservasi_screen.dart';
import '../camping/booking_camping_screen.dart';
import '../penginapan/booking_penginapan_screen.dart';
import '../peralatan/sewa_peralatan_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../profil/profil_screen.dart';
import '../reservasi/tiket_list_screen.dart'; 
import '../tiket/booking_tiket_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final List<String> _kategoriList = ['🌿 Semua', '🏔️ Gunung', '🌊 Pantai', '💧 Air Terjun', '🏛️ Budaya'];
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<WisataModel> _dummyWisataMaster = [
    WisataModel(id: 1, nama: 'Galunggung Peak', deskripsi: 'Kawah indah.', alamat: 'Sukaratu', hargaTiket: 25000, kuotaHarian: 500, status: 'active', rating: 4.8, emoji: '🌋'),
    WisataModel(id: 2, nama: 'Curug Cimedang', deskripsi: 'Air terjun alami.', alamat: 'Sariwangi', hargaTiket: 15000, kuotaHarian: 300, status: 'active', rating: 4.9, emoji: '💧'),
    WisataModel(id: 3, nama: 'Pantai Karang Tawulan', deskripsi: 'Pantai tebing eksotis.', alamat: 'Cikalong', hargaTiket: 20000, kuotaHarian: 1000, status: 'active', rating: 4.7, emoji: '🌊'),
    WisataModel(id: 4, nama: 'Kampung Naga Cultural', deskripsi: 'Adat budaya sunda.', alamat: 'Salawu', hargaTiket: 10000, kuotaHarian: 200, status: 'active', rating: 4.6, emoji: '🏛️'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WisataProvider>().loadWisata();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1: return _buildJelajahTab();
      case 2: return const TiketListScreen(); 
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
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.explore_rounded, 'label': 'Jelajah'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Riwayat'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.textPrimary.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: items.asMap().entries.map((e) {
              final active = _navIndex == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _navIndex = e.key;
                      if (_navIndex != 1) {
                        _searchQuery = "";
                        _searchController.clear();
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e.value['icon'] as IconData,
                        color: active ? AppColors.primaryGreen : AppColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? AppColors.primaryGreen : AppColors.textMuted,
                        ),
                      ),
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
      builder: (context, wisataP, authP, child) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Selamat petualang, 👋', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(authP.user?.nama ?? 'Wisatawan CitiisGo', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                        
                        // INTEGRASI BADGE LONCENG NOTIFIKASI AKTIF
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
                          },
                          child: Consumer<NotifikasiProvider>(
                            builder: (context, notifP, child) {
                              final bool adaPesanBelumDibaca = notifP.listNotifikasi.any((n) => !n.isRead);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                                    child: const Center(child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22)),
                                  ),
                                  if (adaPesanBelumDibaca)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        width: 11,
                                        height: 11,
                                        decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF0F7133), width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                  _navIndex = 1; 
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari destinasi alam pilihanmu...',
                                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textMuted),
                                border: InputBorder.none, isDense: true,
                              ),
                            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0F7133), Color(0xFF16A34A)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diskon Spesial Camp!', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Dapatkan potongan tiket hingga 20% khusus bulan ini.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Layanan CitiisGo'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Tiket Masuk',
                          bgColor: AppColors.lightGreen,
                          iconColor: AppColors.primaryGreen,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingTiketScreen(wisataId: 1)));
                          },
                        ),
                        _buildServiceItem(
                          icon: Icons.home_rounded,
                          label: 'Sewa Camp',
                          bgColor: AppColors.lightOrange,
                          iconColor: AppColors.primaryOrange,
                          onTap: () {
                            final targetId = wisataP.allWisata.isNotEmpty ? wisataP.allWisata.first.id : 1;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCampingScreen(wisataId: targetId)));
                          },
                        ),
                        _buildServiceItem(
                          icon: Icons.business_rounded,
                          label: 'Penginapan',
                          bgColor: const Color(0xFFEFF6FF),
                          iconColor: AppColors.info,
                          onTap: () {
                            final targetId = wisataP.allWisata.isNotEmpty ? wisataP.allWisata.first.id : 1;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPenginapanScreen(wisataId: targetId)));
                          },
                        ),
                        _buildServiceItem(
                          icon: Icons.work_rounded,
                          label: 'Sewa Alat',
                          bgColor: AppColors.purpleLight,
                          iconColor: AppColors.purplePrimary,
                          onTap: () {
                            final targetId = wisataP.allWisata.isNotEmpty ? wisataP.allWisata.first.id : 1;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SewaPeralatanScreen(wisataId: targetId)));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Kategori Wisata'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _kategoriList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final labelKategori = _kategoriList[i];
                          final rawName = labelKategori.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                          final mappedKey = i == 0 ? 'Semua' : rawName;
                          final isSelected = wisataP.kategoriAktif == mappedKey;

                          return ChoiceChip(
                            label: Text(labelKategori),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGreen,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSelected ? Colors.transparent : AppColors.borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onSelected: (_) {
                              wisataP.setKategori(mappedKey);
                              setState(() { _navIndex = 1; }); 
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Destinasi Terpopuler'),
                    const SizedBox(height: 16),
                    _buildPopularList(wisataP),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Rekomendasi Terdekat'),
                    const SizedBox(height: 8),
                    _buildNearbyList(wisataP),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2));
  }

  Widget _buildServiceItem({required IconData icon, required String label, required Color bgColor, required Color iconColor, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Icon(icon, color: iconColor, size: 24)),
              ),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularList(WisataProvider provider) {
    final listData = provider.popularWisata.isNotEmpty ? provider.popularWisata : _dummyWisataMaster;
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: listData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _buildWisataCardReal(listData[i]),
      ),
    );
  }

  Widget _buildNearbyList(WisataProvider provider) {
    final listData = provider.nearbyWisata.isNotEmpty ? provider.nearbyWisata : _dummyWisataMaster;
    return Column(children: listData.map((w) => _buildNearbyRowReal(w)).toList());
  }

  Widget _buildWisataCardReal(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        width: 145, padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90, 
              width: double.infinity, 
              decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)), 
              child: Center(child: Text(w.emoji ?? '🏔️', style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 8),
            Text(w.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(w.alamat ?? 'Tasikmalaya', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('⭐ ${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                Text(CurrencyFormatter.formatShort(w.hargaTiket), style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyRowReal(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 60, 
              height: 60, 
              decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)), 
              child: Center(child: Text(w.emoji ?? '🏔️', style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('📍 Kawasan Wisata Citiis — Tasikmalaya', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('⭐ ${w.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(CurrencyFormatter.format(w.hargaTiket), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildJelajahTab() {
    return Consumer<WisataProvider>(
      builder: (_, provider, __) {
        final List<WisataModel> poolData = provider.allWisata.isNotEmpty ? provider.allWisata : _dummyWisataMaster;

        List<WisataModel> hasilFilter = poolData.where((w) {
          final matchQuery = w.nama.toLowerCase().contains(_searchQuery.toLowerCase());
          
          if (provider.kategoriAktif == 'Semua') {
            return matchQuery;
          } else {
            return matchQuery && (w.emoji == _petaEmojiKategori(provider.kategoriAktif));
          }
        }).toList();

        return Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
              color: AppColors.primaryGreen,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() { _searchQuery = val; });
                },
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari destinasi alam pilihanmu...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.cancel, size: 16), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ""; }); }) 
                      : null,
                  filled: true, fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
            
            _buildQuickKategoriFilter(provider),

            Expanded(
              child: hasilFilter.isEmpty
                ? Center(child: Text('Destinasi tidak ditemukan', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w500)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16), 
                    physics: const BouncingScrollPhysics(), 
                    itemCount: hasilFilter.length,
                    itemBuilder: (_, i) {
                      final w = hasilFilter[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderColor.withOpacity(0.4))),
                          child: Row(
                            children: [
                              Container(
                                width: 75, height: 75, 
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(14)), 
                                child: Center(child: Text(w.emoji ?? '🏔️', style: const TextStyle(fontSize: 30))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(w.nama, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('📍 ${w.alamat ?? "Tasikmalaya"}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                                        const SizedBox(width: 2),
                                        Text('${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                        const Spacer(),
                                        Text(CurrencyFormatter.formatShort(w.hargaTiket), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickKategoriFilter(WisataProvider wisataP) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _kategoriList.length,
        itemBuilder: (ctx, i) {
          final labelKategori = _kategoriList[i];
          final rawName = labelKategori.replaceAll(RegExp(r'[^\w\s]'), '').trim();
          final mappedKey = i == 0 ? 'Semua' : rawName;
          final isSelected = wisataP.kategoriAktif == mappedKey;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labelKategori, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 11.5)),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              onSelected: (_) => wisataP.setKategori(mappedKey),
            ),
          );
        },
      ),
    );
  }

  String _petaEmojiKategori(String kat) {
    if (kat == 'Gunung') return '🌋';
    if (kat == 'Air Terjun') return '💧';
    if (kat == 'Pantai') return '🌊';
    if (kat == 'Budaya') return '🏛️';
    return '🏔️';
  }
}