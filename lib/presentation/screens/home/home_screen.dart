import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wisata_model.dart';
import '../../../providers/wisata_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notifikasi_provider.dart';

import '../wisata/wisata_detail_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Load data nyata dari API — bukan dummy lagi
      final wp = context.read<WisataProvider>();
      wp.loadWisata(refresh: true);
      wp.loadKategori();
      // Load notifikasi dari API
      context.read<NotifikasiProvider>().loadNotifikasiDariApi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return _buildJelajahTab();
      case 2:
        return const TiketListScreen();
      case 3:
        return const ProfilScreen();
      default:
        return _buildHomeTab();
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

  // ── Bottom Navigation ──────────────────────────────────────────────────
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
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
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
                        _searchQuery = '';
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

  // ── Tab Beranda ────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return Consumer2<WisataProvider, AuthProvider>(
      builder: (context, wisataP, authP, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await wisataP.loadWisata(refresh: true);
            await wisataP.loadKategori();
          },
          color: AppColors.primaryGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Hero Header ──
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
                              Text(
                                'Selamat petualang, 👋',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // ✅ Nama user dari API (AuthProvider)
                                authP.user?.nama ?? 'Wisatawan CitiisGo',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // ── Tombol Notifikasi ──
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotifikasiScreen(),
                              ),
                            ),
                            child: Consumer<NotifikasiProvider>(
                              builder: (_, notifP, __) {
                                final adaBelumDibaca = notifP.listNotifikasi
                                    .any((n) => !n.isRead);
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    if (adaBelumDibaca)
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          width: 11,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: AppColors.danger,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF0F7133),
                                              width: 1.5,
                                            ),
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
                      // ── Search Bar ──
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
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
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppColors.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
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

              // ── Konten Utama ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner promo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F7133), Color(0xFF16A34A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diskon Spesial Camp! 🏕️',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dapatkan potongan tiket hingga 20% khusus bulan ini.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Layanan CitiisGo ──
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
                              // ✅ wisataId dari wisata pertama di API
                              final id = wisataP.allWisata.isNotEmpty
                                  ? wisataP.allWisata.first.id
                                  : 1;
                              final harga = wisataP.allWisata.isNotEmpty
                                  ? wisataP.allWisata.first.hargaTiket
                                  : 25000;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingTiketScreen(
                                    wisataId: id,
                                    hargaTiket: harga, // ✅ dari API, bukan hardcode
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildServiceItem(
                            icon: Icons.home_rounded,
                            label: 'Sewa Camp',
                            bgColor: AppColors.lightOrange,
                            iconColor: AppColors.primaryOrange,
                            onTap: () {
                              final id = wisataP.allWisata.isNotEmpty
                                  ? wisataP.allWisata.first.id
                                  : 1;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingCampingScreen(wisataId: id),
                                ),
                              );
                            },
                          ),
                          _buildServiceItem(
                            icon: Icons.business_rounded,
                            label: 'Penginapan',
                            bgColor: const Color(0xFFEFF6FF),
                            iconColor: AppColors.info,
                            onTap: () {
                              final id = wisataP.allWisata.isNotEmpty
                                  ? wisataP.allWisata.first.id
                                  : 1;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingPenginapanScreen(wisataId: id),
                                ),
                              );
                            },
                          ),
                          _buildServiceItem(
                            icon: Icons.work_rounded,
                            label: 'Sewa Alat',
                            bgColor: AppColors.purpleLight,
                            iconColor: AppColors.purplePrimary,
                            onTap: () {
                              final id = wisataP.allWisata.isNotEmpty
                                  ? wisataP.allWisata.first.id
                                  : 1;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SewaPeralatanScreen(wisataId: id),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Kategori dari API ──
                      _buildSectionTitle('Kategori Wisata'),
                      const SizedBox(height: 12),
                      _buildKategoriChips(wisataP),
                      const SizedBox(height: 28),

                      // ── Destinasi Terpopuler dari API ──
                      _buildSectionTitle('Destinasi Terpopuler'),
                      const SizedBox(height: 16),
                      _buildPopularList(wisataP),
                      const SizedBox(height: 28),

                      // ── Semua Wisata dari API ──
                      _buildSectionTitle('Semua Destinasi'),
                      const SizedBox(height: 8),
                      _buildAllWisataList(wisataP),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Kategori Chips dari API ────────────────────────────────────────────
  Widget _buildKategoriChips(WisataProvider wisataP) {
    // Gabungkan "Semua" + kategori dari API
    final chips = <String>['Semua', ...wisataP.kategoriList.map((k) => k.nama)];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = chips[i];
          final isSelected = wisataP.kategoriAktif == label;
          return ChoiceChip(
            label: Text(label),
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? Colors.transparent : AppColors.borderColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (_) {
              wisataP.setKategori(label);
            },
          );
        },
      ),
    );
  }

  // ── Daftar Populer dari API ────────────────────────────────────────────
  Widget _buildPopularList(WisataProvider wisataP) {
    if (wisataP.isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => _buildSkeletonCard(),
        ),
      );
    }

    final list = wisataP.popularWisata.isNotEmpty
        ? wisataP.popularWisata
        : wisataP.allWisata;

    if (list.isEmpty) {
      return _buildEmptyState('Belum ada wisata tersedia');
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _buildWisataCard(list[i]),
      ),
    );
  }

  // ── Semua Wisata dari API ──────────────────────────────────────────────
  Widget _buildAllWisataList(WisataProvider wisataP) {
    if (wisataP.isLoading) {
      return Column(
        children: List.generate(3, (_) => _buildSkeletonRow()),
      );
    }

    final list = wisataP.filteredWisata;

    if (list.isEmpty) {
      if (wisataP.error != null) {
        return _buildErrorState(wisataP.error!, () {
          wisataP.loadWisata(refresh: true);
        });
      }
      return _buildEmptyState('Belum ada destinasi untuk kategori ini');
    }

    return Column(
      children: list.map((w) => _buildWisataRow(w)).toList(),
    );
  }

  // ── Tab Jelajah ────────────────────────────────────────────────────────
  Widget _buildJelajahTab() {
    return Consumer<WisataProvider>(
      builder: (_, provider, __) {
        final list = provider.allWisata.where((w) {
          return w.nama.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            // Search Header
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 12,
                16,
                16,
              ),
              color: AppColors.primaryGreen,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari destinasi alam pilihanmu...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Filter Kategori
            Container(
              height: 50,
              padding: const EdgeInsets.only(top: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'Semua',
                  ...provider.kategoriList.map((k) => k.nama),
                ].map((label) {
                  final isSelected = provider.kategoriAktif == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 11.5,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: Colors.white,
                      onSelected: (_) => provider.setKategori(label),
                    ),
                  );
                }).toList(),
              ),
            ),

            // List Wisata dari API
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : list.isEmpty
                      ? Center(
                          child: Text(
                            'Destinasi tidak ditemukan',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              provider.loadWisata(refresh: true),
                          color: AppColors.primaryGreen,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, i) =>
                                _buildJelajahCard(list[i]),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  // ── Widget Cards ───────────────────────────────────────────────────────
  Widget _buildWisataCard(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WisataDetailScreen(wisataId: w.id),
        ),
      ),
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover dari API atau emoji fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: w.cover != null
                  ? Image.network(
                      w.cover!,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildEmojiCover(
                        w.emoji ?? '🏔️',
                        height: 90,
                      ),
                    )
                  : _buildEmojiCover(w.emoji ?? '🏔️', height: 90),
            ),
            const SizedBox(height: 8),
            Text(
              w.nama,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              w.alamat,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '⭐ ${w.rating.toStringAsFixed(1)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatShort(w.hargaTiket),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWisataRow(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WisataDetailScreen(wisataId: w.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: w.cover != null
                  ? Image.network(
                      w.cover!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildEmojiCover(w.emoji ?? '🏔️', size: 60),
                    )
                  : _buildEmojiCover(w.emoji ?? '🏔️', size: 60),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${w.alamat}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⭐ ${w.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(w.hargaTiket),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJelajahCard(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WisataDetailScreen(wisataId: w.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: w.cover != null
                  ? Image.network(
                      w.cover!,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildEmojiCover(w.emoji ?? '🏔️', size: 75),
                    )
                  : _buildEmojiCover(w.emoji ?? '🏔️', size: 75),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${w.alamat}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 15,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        w.rating.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.formatShort(w.hargaTiket),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────
  Widget _buildEmojiCover(String emoji, {double? size, double? height}) {
    return Container(
      width: size,
      height: size ?? height,
      color: AppColors.lightGreen,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size != null ? size * 0.45 : 32)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 24)),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, color: AppColors.borderColor),
          const SizedBox(height: 6),
          Container(height: 10, width: 80, color: AppColors.borderColor),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 13, color: AppColors.borderColor),
                const SizedBox(height: 6),
                Container(height: 10, width: 120, color: AppColors.borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.map_outlined, size: 48, color: AppColors.borderColor),
            const SizedBox(height: 12),
            Text(
              msg,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String msg, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              msg,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
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
}