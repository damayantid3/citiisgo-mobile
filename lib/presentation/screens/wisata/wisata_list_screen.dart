import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const colorPrimary  = Color(0xFF0F7133);
  static const colorSlate900 = Color(0xFF0F172A);
  static const colorSlate500 = Color(0xFF64748B);
  static const colorSlate200 = Color(0xFFE2E8F0);

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
      setState(() { _page = 1; _hasMore = true; _loading = true; });
    }
    final r = await _repo.getWisata(
      search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null,
      kategoriId: _selectedKat,
      sort: _sortBy == 'rating' ? 'rating' : null,
      page: _page,
    );
    if (!mounted) return;
    final list = (r['data'] as List).cast<WisataModel>();
    setState(() {
      if (reset) { _wisata = list; } else { _wisata.addAll(list); }
      _hasMore = (r['current_page'] ?? 1) < (r['last_page'] ?? 1);
      _loading = false;
    });
  }

  Future<void> _search() async => _loadWisata(reset: true);

  void _filterBottomSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setBS) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: colorSlate200, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Urutkan & Filter', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: colorSlate900)),
            TextButton(
              onPressed: () { setState(() { _selectedKat = null; _sortBy = 'terbaru'; }); _loadWisata(reset: true); Navigator.pop(ctx); },
              child: Text('Reset', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Urutan Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: colorSlate900)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in [('terbaru', '🕐 Terbaru'), ('rating', '⭐ Rating Terbaik'), ('harga_asc', '💰 Termurah')])
              GestureDetector(
                onTap: () => setBS(() => _sortBy = s.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: _sortBy == s.$1 ? colorPrimary : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                  child: Text(s.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _sortBy == s.$1 ? Colors.white : colorSlate500)),
                ),
              ),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () { _loadWisata(reset: true); Navigator.pop(ctx); },
              style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: Text('Terapkan Filter', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF064E3B), colorPrimary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
          ),
          child: Column(children: [
            Row(children: [
              Expanded(child: Text('Eksplorasi Destinasi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
              GestureDetector(
                onTap: () => setState(() => _isGrid = !_isGrid),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              height: 48,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Icon(Icons.search_rounded, color: colorSlate500, size: 20)),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Cari nama tempat wisata...', hintStyle: GoogleFonts.plusJakartaSans(color: colorSlate500, fontSize: 13.5, fontWeight: FontWeight.w500), isDense: true),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: colorSlate900),
                )),
                GestureDetector(
                  onTap: _filterBottomSheet,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('Filter', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: colorPrimary))
          : _wisata.isEmpty
            ? _emptyState()
            : RefreshIndicator(
                onRefresh: () => _loadWisata(reset: true),
                color: colorPrimary,
                child: _isGrid ? _buildGrid() : _buildList(),
              ),
        ),
      ]),
    );
  }

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.all(16),
    physics: const BouncingScrollPhysics(),
    itemCount: _wisata.length,
    itemBuilder: (_, i) => _wisataListCard(_wisata[i]),
  );

  Widget _buildGrid() => GridView.builder(
    padding: const EdgeInsets.all(16),
    physics: const BouncingScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .78),
    itemCount: _wisata.length,
    itemBuilder: (_, i) => _wisataGridCard(_wisata[i]),
  );

  Widget _wisataListCard(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Row(children: [
          Container(
            width: 85, height: 85,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            ),
            child: const Center(child: Icon(Icons.landscape_rounded, color: colorPrimary, size: 32)),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: colorSlate900), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 12, color: colorSlate500),
                const SizedBox(width: 2),
                Expanded(child: Text(w.alamat, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: colorSlate500, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                const SizedBox(width: 2),
                Text('${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: colorSlate900)),
                const Spacer(),
                Text('Rp ${_fmt(w.hargaTiket)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: colorPrimary)),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _wisataGridCard(WisataModel w) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(wisataId: w.id))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 16)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 105,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: const Center(child: Icon(Icons.landscape_rounded, color: colorPrimary, size: 36)),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.nama, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: colorSlate900), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(w.alamat, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: colorSlate500, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text('${w.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: colorSlate900)),
                const Spacer(),
                Text('Rp ${_fmt(w.hargaTiket)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: colorPrimary)),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('Wisata Tidak Ditemukan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: colorSlate900)),
    const SizedBox(height: 16),
    OutlinedButton(
      onPressed: () { _searchCtrl.clear(); setState(() => _selectedKat = null); _loadWisata(reset: true); },
      style: OutlinedButton.styleFrom(side: const BorderSide(color: colorPrimary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Text('Reset Filter', style: GoogleFonts.plusJakartaSans(color: colorPrimary, fontWeight: FontWeight.w700)),
    ),
  ]));

  String _fmt(int h) { if (h >= 1000) return '${(h / 1000).toStringAsFixed(0)}rb'; return h.toString(); }
}