import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/peralatan_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

class SewaPeralatanScreen extends StatefulWidget {
  final int wisataId;
  const SewaPeralatanScreen({super.key, required this.wisataId});
  @override
  State<SewaPeralatanScreen> createState() => _SewaPeralatanScreenState();
}

class _SewaPeralatanScreenState extends State<SewaPeralatanScreen> {
  final _wisataRepo  = WisataRepository();
  final _bookingRepo = BookingRepository();
  List<PeralatanModel> _peralatan = [];
  final Map<int, int> _cart = {}; // peralatan_id -> jumlah
  DateTime _mulai   = DateTime.now().add(const Duration(days: 1));
  DateTime _selesai = DateTime.now().add(const Duration(days: 2));
  bool _loading = false, _loadingData = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final data = await _wisataRepo.getPeralatan(widget.wisataId);
    if (mounted) setState(() { _peralatan = data; _loadingData = false; });
  }

  int get _durasi => _selesai.difference(_mulai).inDays.abs().clamp(1, 999);

  int get _total {
    int t = 0;
    _cart.forEach((id, qty) {
      final p = _peralatan.firstWhere((x) => x.id == id, orElse: () => PeralatanModel(id: 0, nama: '', hargaSewaDerHari: 0, totalStok: 0, stokTersedia: 0));
      t += p.hargaSewaDerHari * qty * _durasi;
    });
    return t;
  }

  List<Map<String, dynamic>> get _cartItems => _cart.entries
    .where((e) => e.value > 0)
    .map((e) {
      final p = _peralatan.firstWhere((x) => x.id == e.key, orElse: () => PeralatanModel(id: 0, nama: '-', hargaSewaDerHari: 0, totalStok: 0, stokTersedia: 0));
      return {'peralatan_id': e.key, 'jumlah': e.value, 'nama': p.nama, 'harga': p.hargaSewaDerHari};
    }).toList();

  Future<void> _pilihTanggal(bool isMulai) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isMulai ? _mulai : _selesai,
      firstDate: isMulai ? DateTime.now() : _mulai.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: const Color(0xFF6A1B9A))),
        child: child!,
      ),
    );
    if (d != null) setState(() {
      if (isMulai) { _mulai = d; if (!_selesai.isAfter(_mulai)) _selesai = _mulai.add(const Duration(days: 1)); }
      else _selesai = d;
    });
  }

  Future<void> _sewa() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 peralatan'), backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _loading = true);
    final r = await _bookingRepo.createSewaPeralatan({
      'wisata_id': widget.wisataId,
      'tanggal_mulai': _fmtDate(_mulai),
      'tanggal_selesai': _fmtDate(_selesai),
      'items': _cartItems.map((i) => {'peralatan_id': i['peralatan_id'], 'jumlah': i['jumlah']}).toList(),
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['success'] == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PembayaranScreen(
        paymentUrl: r['payment_url'] ?? '',
        kodeBooking: 'SGS-${DateTime.now().millisecondsSinceEpoch}',
        totalHarga: _total,
        layanan: 'Sewa Peralatan',
      )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r['message'] ?? 'Gagal'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🎒 Sewa Peralatan', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('Pilih peralatan yang dibutuhkan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                if (_cartItems.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_cartItems.length} item', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
            ]),
          )),
        ),

        Expanded(child: _loadingData
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              // Tanggal sewa
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('📅 Periode Sewa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _dateTile('Mulai Sewa', _mulai, () => _pilihTanggal(true))),
                    Container(width: 1, height: 50, color: AppColors.borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(child: _dateTile('Selesai Sewa', _selesai, () => _pilihTanggal(false))),
                  ]),
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Text('⏱️', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Text('$_durasi hari sewa', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A1B9A), fontSize: 13)),
                    ])),
                ])),
              const SizedBox(height: 14),

              // Daftar peralatan
              const Align(alignment: Alignment.centerLeft,
                child: Text('🎒 Pilih Peralatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),

              ..._peralatan.map((p) {
                final qty = _cart[p.id] ?? 0;
                final isSelected = qty > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF3E5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: isSelected ? const Color(0xFF6A1B9A) : AppColors.borderColor, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Container(width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE1BEE7) : AppColors.background,
                        borderRadius: BorderRadius.circular(11)),
                      child: Center(child: Text(_getEmoji(p.nama), style: const TextStyle(fontSize: 24)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      const SizedBox(height: 3),
                      Row(children: [
                        _chip('Stok: ${p.stokTersedia}'),
                        const SizedBox(width: 6),
                        Text('Rp ${_fmt(p.hargaSewaDerHari)}/hari',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w700)),
                      ]),
                      if (p.deskripsi != null) Text(p.deskripsi!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    const SizedBox(width: 8),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      if (qty > 0) ...[
                        GestureDetector(
                          onTap: () => setState(() { if (qty > 0) _cart[p.id] = qty - 1; if (_cart[p.id] == 0) _cart.remove(p.id); }),
                          child: Container(width: 30, height: 30,
                            decoration: BoxDecoration(color: const Color(0xFFE1BEE7), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.remove_rounded, color: Color(0xFF6A1B9A), size: 16)),
                        ),
                        Container(width: 34, alignment: Alignment.center,
                          child: Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                      ],
                      GestureDetector(
                        onTap: qty < p.stokTersedia ? () => setState(() => _cart[p.id] = qty + 1) : null,
                        child: Container(width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: qty < p.stokTersedia ? const Color(0xFF6A1B9A) : AppColors.background,
                            borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add_rounded, color: qty < p.stokTersedia ? Colors.white : AppColors.textMuted, size: 16)),
                      ),
                    ]),
                  ]),
                );
              }).toList(),

              if (_cartItems.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                  child: Column(children: [
                    const Row(children: [Text('🧾 Ringkasan Sewa', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))]),
                    const Divider(height: 14),
                    ..._cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${item['nama']} ×${item['jumlah']}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        Text('Rp ${_fmt((item['harga'] as int) * (item['jumlah'] as int) * _durasi)}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ]),
                    )).toList(),
                    _sumRow('Durasi', '$_durasi hari'),
                    const Divider(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('Rp ${_fmt(_total)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF6A1B9A))),
                    ]),
                  ])),
              ],
              const SizedBox(height: 80),
            ])),
        ),

        // Bottom
        Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 12, offset: const Offset(0, -4))]),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_cartItems.length} item dipilih', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(_cartItems.isEmpty ? 'Rp 0' : 'Rp ${_fmt(_total)}',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF6A1B9A))),
            ]),
            const Spacer(),
            SizedBox(width: 170, height: 48,
              child: ElevatedButton(
                onPressed: (_loading || _cartItems.isEmpty) ? null : _sewa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('🎒 Sewa Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              )),
          ])),
      ]),
    );
  }

  Widget _dateTile(String lbl, DateTime d, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${d.day} ${_bulan(d.month)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF6A1B9A))),
        Text(d.year.toString(), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
  );

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(5)),
    child: Text(t, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
  );

  Widget _sumRow(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    ]),
  );

  String _getEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('tenda')) return '⛺';
    if (n.contains('sleeping') || n.contains('bag')) return '💤';
    if (n.contains('carrier') || n.contains('backpack')) return '🎒';
    if (n.contains('kompor')) return '🏕️';
    if (n.contains('lampu') || n.contains('lamp')) return '💡';
    if (n.contains('matras')) return '🧗';
    return '🔧';
  }

  String _fmt(int h) { if (h >= 1000000) return '${(h/1e6).toStringAsFixed(1)}jt'; if (h >= 1000) return '${(h/1000).toStringAsFixed(0)}rb'; return h.toString(); }
  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _bulan(int m) => ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'][m];
}