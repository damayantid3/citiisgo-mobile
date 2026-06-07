import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/kategori_model.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/wisata_repository.dart';
import 'wisata_detail_screen.dart';

class WisataListScreen extends StatefulWidget {
  const WisataListScreen({super.key});
  @override
  State<WisataListScreen> createState() => _WisataListScreenState();
}

class _WisataListScreenState extends State<WisataListScreen> {
  final _repo       = WisataRepository();
  final _searchCtrl = TextEditingController();
  List<KategoriModel> _kategori   = [];
  List<WisataModel>   _wisata     = [];
  int?  _selectedKat;
  String _sortBy    = 'terbaru';
  bool  _loading    = true;
  bool  _isGrid     = false;
  int   _page       = 1;
  bool  _hasMore    = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(() {
      if (_searchCtrl.text.length >= 2 || _searchCtrl.text.isEmpty) _search();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    await Future.wait([_loadKategori(), _loadWisata(reset: true)]);
  }

  Future<void> _loadKategori() async {
    final k = await _repo.getKategori();
    if (mounted) setState(() => _kategori = k);
  }

  Future<void> _loadWisata({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _loading = true;
      });
    }
    final r = await _repo.getWisata(
      search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null,
      kategoriId: _selectedKat,
      sort: _sortBy == 'rating' ? 'rating' : null,
      page: _page,
    );
    if (!mounted) {
      return;
    }
    final list = (r['data'] as List).cast<WisataModel>();
    setState(() {
      if (reset) {
        _wisata = list;
      } else {
        _wisata.addAll(list);
      }
      _hasMore = (r['current_page'] ?? 1) < (r['last_page'] ?? 1);
      _loading = false;
    });
  }

  Future<void> _search() async => _loadWisata(reset: true);

  void _filterBottomSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setBS) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('🔍 Filter & Urutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () { setState(() { _selectedKat = null; _sortBy = 'terbaru'; }); _loadWisata(reset: true); Navigator.pop(ctx); },
              child: const Text('Reset', style: TextStyle(color: AppColors.danger)),
            ),
          ]),
          const SizedBox(height: 16),
          const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _filterChip(null, '🌐 Semua', _selectedKat == null, () => setBS(() => _selectedKat = null)),
            ..._kategori.map((k) => _filterChip(k.id, '${k.ikon ?? ''} ${k.nama}', _selectedKat == k.id, () => setBS(() => _selectedKat = k.id))),
          ]),
          const SizedBox(height: 16),
          const Text('Urutkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            for (final s in [('terbaru', '🕐 Terbaru'), ('rating', '⭐ Rating'), ('harga_asc', '💰 Harga Terendah'), ('harga_desc', '💰 Harga Tertinggi')])
              GestureDetector(
                onTap: () => setBS(() => _sortBy = s.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _sortBy == s.$1 ? AppColors.primaryGreen : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _sortBy == s.$1 ? AppColors.primaryGreen : AppColors.borderColor),
                  ),
                  child: Text(s.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _sortBy == s.$1 ? Colors.white : AppColors.textSecondary)),
                ),
              ),
          ]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () { _loadWisata(reset: true); Navigator.pop(ctx); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('✅ Terapkan Filter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }

  Widget _filterChip(int? id, String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryGreen : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.borderColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
    ),
  );

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(children: [
              Row(children: [
                const Expanded(child: Text('🔍 Jelajah Wisata', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
                GestureDetector(
                  onTap: () => setState(() => _isGrid = !_isGrid),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(10)),
                    child: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              // Search bar
              Container(
                height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20)),
                  Expanded(child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Cari nama wisata, lokasi...', hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5), isDense: true),
                    style: const TextStyle(fontSize: 14),
                  )),
                  GestureDetector(
                    onTap: _filterBottomSheet,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                      child: const Row(children: [
                        Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Filter', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          )),
        ),

        // Kategori chips
        if (_kategori.isNotEmpty) Container(
          height: 44,
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: _kategori.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              if (i == 0) {
                final sel = _selectedKat == null;
                return GestureDetector(
                  onTap: () { setState(() => _selectedKat = null); _loadWisata(reset: true); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryGreen : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primaryGreen : AppColors.borderColor),
                    ),
                    child: Text('🌐 Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              }
              final k = _kategori[i - 1];
              final sel = _selectedKat == k.id;
              return GestureDetector(
                onTap: () { setState(() => _selectedKat = k.id); _loadWisata(reset: true); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryGreen : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.primaryGreen : AppColors.borderColor),
                  ),
                  child: Text('${k.ikon ?? ''} ${k.nama}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
                ),
              );
            },
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(children: [
            Text('${_wisata.length} wisata ditemukan', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (_selectedKat != null || _searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() => _selectedKat = null); _loadWisata(reset: true); },
                child: const Text('✕ Reset', style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
          ]),
        ),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _wisata.isEmpty
            ? _emptyState()
            : RefreshIndicator(
                onRefresh: () => _loadWisata(reset: true),
                color: AppColors.primaryGreen,
                child: _isGrid ? _buildGrid() : _buildList(),
              ),
        ),
      ]),
    );
  }

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
    itemCount: _wisata.length + (_hasMore ? 1 : 0),
    itemBuilder: (_, i) {
      if (i == _wisata.length) return _loadMoreBtn();
      return _wisataListCard(_wisata[i]);
    },
  );

  Widget _buildGrid() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .75),
    itemCount: _wisata.length + (_hasMore ? 1 : 0),
    itemBuilder: (_, i) {
      if (i == _wisata.length) return _loadMoreBtn();
      return _wisataGridCard(_wisata[i]);
    },
  );

  Widget _wisataListCard(WisataModel w) {
    final emojis = {'Alam': '🏔️', 'Pantai': '🏖️', 'Gunung': '⛰️', 'Budaya': '🏛️', 'Air Terjun': '💧', 'Danau': '🏞️'};
    final ico = emojis[w.kategori?.nama] ?? '🌿';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryGreen.withAlpha(204), AppColors.mediumGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
            ),
            child: Center(child: Text(ico, style: const TextStyle(fontSize: 38))),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(w.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(5)),
                  child: Text(w.kategori?.nama ?? '', style: const TextStyle(fontSize: 9.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 2),
                Expanded(child: Text(w.alamat, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                const SizedBox(width: 2),
                Text('${w.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: Text('Rp ${_fmt(w.hargaTiket)}/org', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textMuted),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _wisataGridCard(WisataModel w) {
    final emojis = {'Alam': '🏔️', 'Pantai': '🏖️', 'Gunung': '⛰️', 'Budaya': '🏛️', 'Air Terjun': '💧'};
    final ico = emojis[w.kategori?.nama] ?? '🌿';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryGreen.withAlpha(204), AppColors.mediumGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Stack(children: [
              Center(child: Text(ico, style: const TextStyle(fontSize: 44))),
              Positioned(top: 8, right: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(6)),
                child: Text(w.kategori?.nama ?? '', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(w.alamat, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
                const SizedBox(width: 2),
                Text('${w.rating}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('Rp ${_fmt(w.hargaTiket)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _loadMoreBtn() => Center(child: Padding(
    padding: const EdgeInsets.all(14),
    child: OutlinedButton(
      onPressed: () { setState(() => _page++); _loadWisata(); },
      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
      child: const Text('Muat Lebih Banyak', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
    ),
  ));

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('🔍', style: TextStyle(fontSize: 56)),
    const SizedBox(height: 14),
    const Text('Wisata tidak ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    const SizedBox(height: 6),
    const Text('Coba kata kunci lain atau ubah filter', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
    const SizedBox(height: 18),
    OutlinedButton(
      onPressed: () { _searchCtrl.clear(); setState(() => _selectedKat = null); _loadWisata(reset: true); },
      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
      child: const Text('Reset Filter', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
    ),
  ]));

  String _fmt(int h) { if (h >= 1000) return '${(h / 1000).toStringAsFixed(0)}rb'; return h.toString(); }
}