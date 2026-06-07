import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/kamar_model.dart';
import '../../../data/models/penginapan_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

// ══════════════════════════════════════════════════════════════
// BOOKING PENGINAPAN SCREEN
// ══════════════════════════════════════════════════════════════
class BookingPenginapanScreen extends StatefulWidget {
  final int wisataId;
  const BookingPenginapanScreen({super.key, required this.wisataId});
  @override
  State<BookingPenginapanScreen> createState() => _BookingPenginapanScreenState();
}

class _BookingPenginapanScreenState extends State<BookingPenginapanScreen> {
  final _wisataRepo  = WisataRepository();
  final _bookingRepo = BookingRepository();
  List<PenginapanModel> _penginapanList = [];
  KamarModel? _selectedKamar;
  PenginapanModel? _selectedPenginapan;
  DateTime _checkin  = DateTime.now().add(const Duration(days: 1));
  DateTime _checkout = DateTime.now().add(const Duration(days: 2));
  int _jumlahTamu = 1;
  bool _loading = false, _loadingData = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final data = await _wisataRepo.getPenginapan(widget.wisataId);
    if (mounted) setState(() {
      _penginapanList = data;
      if (data.isNotEmpty) {
        _selectedPenginapan = data.first;
        if (data.first.kamar.isNotEmpty) _selectedKamar = data.first.kamar.first;
      }
      _loadingData = false;
    });
  }

  int get _durasi => _checkout.difference(_checkin).inDays.abs().clamp(1, 999);
  int get _total  => (_selectedKamar?.hargaPerMalam ?? 0) * _durasi;

  Future<void> _pilihTanggal(bool isCheckin) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isCheckin ? _checkin : _checkout,
      firstDate: isCheckin ? DateTime.now() : _checkin.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen)),
        child: child!,
      ),
    );
    if (d != null) setState(() {
      if (isCheckin) { _checkin = d; if (!_checkout.isAfter(_checkin)) _checkout = _checkin.add(const Duration(days: 1)); }
      else _checkout = d;
    });
  }

  Future<void> _booking() async {
    if (_selectedKamar == null) return;
    setState(() => _loading = true);
    final r = await _bookingRepo.createBookingCamping({
      'kamar_id': _selectedKamar!.id,
      'tanggal_checkin': _fmtDate(_checkin),
      'tanggal_checkout': _fmtDate(_checkout),
      'jumlah_tamu': _jumlahTamu,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['success'] == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PembayaranScreen(
        paymentUrl: r['payment_url'] ?? '',
        kodeBooking: 'BGP-${DateTime.now().millisecondsSinceEpoch}',
        totalHarga: _total,
        layanan: 'Booking Penginapan',
      )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r['message'] ?? 'Gagal booking'),
        backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating,
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
            gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🏨 Booking Penginapan', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                Text('Pilih kamar & tanggal menginap', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          )),
        ),

        Expanded(child: _loadingData
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              // Pilih penginapan
              if (_penginapanList.length > 1) ...[
                const _SectionTitle('🏨 Pilih Penginapan'),
                const SizedBox(height: 8),
                ...(_penginapanList.map((p) => GestureDetector(
                  onTap: () => setState(() {
                    _selectedPenginapan = p;
                    _selectedKamar = p.kamar.isNotEmpty ? p.kamar.first : null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedPenginapan?.id == p.id ? const Color(0xFFE3F2FD) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedPenginapan?.id == p.id ? const Color(0xFF1565C0) : AppColors.borderColor),
                    ),
                    child: Row(children: [
                      const Text('🏨', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        if (p.alamat != null) Text(p.alamat!, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ])),
                      if (_selectedPenginapan?.id == p.id) const Icon(Icons.check_circle_rounded, color: Color(0xFF1565C0), size: 20),
                    ]),
                  ),
                ))).toList(),
                const SizedBox(height: 12),
              ],

              // Pilih tipe kamar
              if (_selectedPenginapan != null && _selectedPenginapan!.kamar.isNotEmpty) ...[
                const _SectionTitle('🛏️ Pilih Tipe Kamar'),
                const SizedBox(height: 8),
                ..._selectedPenginapan!.kamar.map((k) => GestureDetector(
                  onTap: () => setState(() { _selectedKamar = k; if (_jumlahTamu > k.kapasitas) _jumlahTamu = k.kapasitas; }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _selectedKamar?.id == k.id ? const Color(0xFFE3F2FD) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedKamar?.id == k.id ? const Color(0xFF1565C0) : AppColors.borderColor, width: _selectedKamar?.id == k.id ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _selectedKamar?.id == k.id ? const Color(0xFFE3F2FD) : AppColors.background,
                          borderRadius: BorderRadius.circular(11)),
                        child: const Center(child: Text('🛏️', style: TextStyle(fontSize: 22)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(k.tipeKamar, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        const SizedBox(height: 3),
                        Row(children: [
                          _chip('👥 ${k.kapasitas} org'),
                          const SizedBox(width: 6),
                          _chip('🏠 ${k.totalKamar} kamar'),
                        ]),
                        if (k.deskripsi != null) ...[
                          const SizedBox(height: 4),
                          Text(k.deskripsi!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ])),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Rp ${_fmt(k.hargaPerMalam)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1565C0), fontSize: 14)),
                        const Text('/malam', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        if (!k.tersedia) Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(5)),
                          child: const Text('Penuh', style: TextStyle(fontSize: 9.5, color: AppColors.danger, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ]),
                  ),
                )).toList(),
                const SizedBox(height: 12),
              ],

              // Tanggal
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('📅 Tanggal Menginap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _dateTile('Check-In', _checkin, () => _pilihTanggal(true), const Color(0xFF1565C0))),
                    Container(width: 1, height: 50, color: AppColors.borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(child: _dateTile('Check-Out', _checkout, () => _pilihTanggal(false), const Color(0xFF1565C0))),
                  ]),
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Text('🌙', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Text('$_durasi malam menginap', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1565C0), fontSize: 13)),
                    ])),
                ])),
              const SizedBox(height: 12),

              // Jumlah tamu
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                child: Row(children: [
                  const Expanded(child: Text('👥 Jumlah Tamu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
                  _cBtn(Icons.remove_rounded, _jumlahTamu > 1, () { if (_jumlahTamu > 1) setState(() => _jumlahTamu--); }),
                  Container(width: 50, alignment: Alignment.center,
                    child: Text('$_jumlahTamu', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                  _cBtn(Icons.add_rounded, _jumlahTamu < (_selectedKamar?.kapasitas ?? 4),
                    () { if (_jumlahTamu < (_selectedKamar?.kapasitas ?? 4)) setState(() => _jumlahTamu++); }),
                ])),
              const SizedBox(height: 12),

              // Ringkasan
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                child: Column(children: [
                  const Row(children: [Text('📋 Ringkasan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))]),
                  const Divider(height: 14),
                  _sumRow('Kamar', _selectedKamar?.tipeKamar ?? '-'),
                  _sumRow('Harga/malam', 'Rp ${_fmt(_selectedKamar?.hargaPerMalam ?? 0)}'),
                  _sumRow('Durasi', '$_durasi malam'),
                  _sumRow('Tamu', '$_jumlahTamu orang'),
                  const Divider(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Rp ${_fmt(_total)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1565C0))),
                  ]),
                ])),
              const SizedBox(height: 80),
            ])),
        ),

        // Bottom
        Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 12, offset: const Offset(0, -4))]),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Bayar', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('Rp ${_fmt(_total)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
            ]),
            const Spacer(),
            SizedBox(width: 170, height: 48,
              child: ElevatedButton(
                onPressed: (_loading || _selectedKamar == null) ? null : _booking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('🏨 Booking Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              )),
          ])),
      ]),
    );
  }

  Widget _dateTile(String lbl, DateTime d, VoidCallback onTap, Color color) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl, style: TextStyle(fontSize: 10.5, color: color.withOpacity(.7), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${d.day} ${_bulan(d.month)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
        Text(d.year.toString(), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
  );

  Widget _cBtn(IconData ico, bool enabled, VoidCallback onTap) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(width: 38, height: 38,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF1565C0) : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: enabled ? const Color(0xFF1565C0) : AppColors.borderColor)),
      child: Icon(ico, color: enabled ? Colors.white : AppColors.textMuted, size: 18)),
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

  String _fmt(int h) { if (h >= 1000000) return '${(h/1e6).toStringAsFixed(1)}jt'; if (h >= 1000) return '${(h/1000).toStringAsFixed(0)}rb'; return h.toString(); }
  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _bulan(int m) => ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'][m];
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
    Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800));
}