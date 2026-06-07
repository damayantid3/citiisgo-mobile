import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/paket_camping_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/wisata_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

class BookingCampingScreen extends StatefulWidget {
  final int wisataId;
  const BookingCampingScreen({super.key, required this.wisataId});
  @override
  State<BookingCampingScreen> createState() => _BookingCampingScreenState();
}

class _BookingCampingScreenState extends State<BookingCampingScreen> {
  final _wisataRepo  = WisataRepository();
  final _bookingRepo = BookingRepository();
  List<PaketCampingModel> _pakets = [];
  PaketCampingModel? _selected;
  DateTime _checkin  = DateTime.now().add(const Duration(days: 1));
  DateTime _checkout = DateTime.now().add(const Duration(days: 2));
  int _jumlahTamu = 1;
  bool _loading = false, _loadingPaket = true;

  @override
  void initState() { super.initState(); _loadPaket(); }

  Future<void> _loadPaket() async {
    final p = await _wisataRepo.getPaketCamping(widget.wisataId);
    if (mounted) setState(() { _pakets = p; _loadingPaket = false; if (p.isNotEmpty) _selected = p.first; });
  }

  int get _durasi => _checkout.difference(_checkin).inDays.abs().clamp(1, 999);
  int get _total  => (_selected?.hargaPerMalam ?? 0) * _durasi;

  Future<void> _pilihTanggal(bool isCheckin) async {
    final first = isCheckin ? DateTime.now() : _checkin.add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: isCheckin ? _checkin : _checkout,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen)),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isCheckin) { _checkin = d; if (!_checkout.isAfter(_checkin)) _checkout = _checkin.add(const Duration(days: 1)); }
        else _checkout = d;
      });
    }
  }

  Future<void> _booking() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    final r = await _bookingRepo.createBookingCamping({
      'paket_camping_id': _selected!.id,
      'tanggal_checkin': _fmtDate(_checkin),
      'tanggal_checkout': _fmtDate(_checkout),
      'jumlah_tamu': _jumlahTamu,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['success'] == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PembayaranScreen(
        paymentUrl: r['payment_url'] ?? '',
        kodeBooking: 'BCP-${DateTime.now().millisecondsSinceEpoch}',
        totalHarga: _total,
        layanan: _selected?.namaPaket ?? 'Booking Camping',
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
        _buildHeader(),
        Expanded(child: _loadingPaket
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _buildPaketList(),
              const SizedBox(height: 14),
              _buildDateSection(),
              const SizedBox(height: 14),
              _buildTamuSection(),
              const SizedBox(height: 14),
              _buildSummary(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
        _buildBottomBar(),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFE65100), AppColors.primaryOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
          Text('⛺ Booking Camping', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          Text('Pilih paket & tanggal camping', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
      ]),
    )),
  );

  Widget _buildPaketList() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Pilih Paket Camping', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    const SizedBox(height: 10),
    ..._pakets.map((p) => GestureDetector(
      onTap: () => setState(() { _selected = p; if (_jumlahTamu > p.kapasitasTamu) _jumlahTamu = p.kapasitasTamu; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _selected?.id == p.id ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _selected?.id == p.id ? AppColors.primaryOrange : AppColors.borderColor, width: _selected?.id == p.id ? 1.5 : 1),
          boxShadow: _selected?.id == p.id ? [BoxShadow(color: AppColors.primaryOrange.withOpacity(.15), blurRadius: 12)] : [],
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: _selected?.id == p.id ? AppColors.primaryOrange.withOpacity(.15) : AppColors.background,
              borderRadius: BorderRadius.circular(11)),
            child: const Center(child: Text('⛺', style: TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.namaPaket, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(height: 3),
            Row(children: [
              _tagChip('👥 ${p.kapasitasTamu} orang'),
              const SizedBox(width: 6),
              _tagChip('🏕️ ${p.totalSlot} slot'),
            ]),
            if (p.deskripsi != null) ...[
              const SizedBox(height: 4),
              Text(p.deskripsi!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Rp ${_fmt(p.hargaPerMalam)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryOrange, fontSize: 14)),
            const Text('/malam', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            if (_selected?.id == p.id) const Icon(Icons.check_circle_rounded, color: AppColors.primaryOrange, size: 18),
          ]),
        ]),
      ),
    )).toList(),
  ]);

  Widget _buildDateSection() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📅 Tanggal Camping', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _dateTile('Check-In', _checkin, () => _pilihTanggal(true))),
        Container(width: 1, height: 50, color: AppColors.borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
        Expanded(child: _dateTile('Check-Out', _checkout, () => _pilihTanggal(false))),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(9)),
        child: Row(children: [
          const Text('🌙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('Durasi: $_durasi malam', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen, fontSize: 13)),
        ]),
      ),
    ]),
  );

  Widget _dateTile(String lbl, DateTime date, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${date.day} ${_bulan(date.month)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
        Text(date.year.toString(), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _buildTamuSection() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('👥 Jumlah Tamu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        if (_selected != null) Text('Maks. ${_selected!.kapasitasTamu} orang', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
      ]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _counterBtn(Icons.remove_rounded, _jumlahTamu > 1, () { if (_jumlahTamu > 1) setState(() => _jumlahTamu--); }),
        Container(
          width: 70, alignment: Alignment.center,
          child: Text('$_jumlahTamu', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ),
        _counterBtn(Icons.add_rounded, _jumlahTamu < (_selected?.kapasitasTamu ?? 10),
          () { if (_jumlahTamu < (_selected?.kapasitasTamu ?? 10)) setState(() => _jumlahTamu++); }),
      ]),
    ]),
  );

  Widget _counterBtn(IconData ico, bool enabled, VoidCallback onTap) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primaryGreen : AppColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: enabled ? AppColors.primaryGreen : AppColors.borderColor),
      ),
      child: Icon(ico, color: enabled ? Colors.white : AppColors.textMuted, size: 20),
    ),
  );

  Widget _buildSummary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
    child: Column(children: [
      const Row(children: [Text('📋 Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))]),
      const Divider(height: 14),
      _sumRow('Paket', _selected?.namaPaket ?? '-'),
      _sumRow('Harga/malam', 'Rp ${_fmt(_selected?.hargaPerMalam ?? 0)}'),
      _sumRow('Durasi', '$_durasi malam'),
      _sumRow('Jumlah tamu', '$_jumlahTamu orang'),
      _sumRow('Check-in', '${_checkin.day} ${_bulan(_checkin.month)} ${_checkin.year}'),
      _sumRow('Check-out', '${_checkout.day} ${_bulan(_checkout.month)} ${_checkout.year}'),
      const Divider(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        Text('Rp ${_fmt(_total)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primaryGreen)),
      ]),
    ]),
  );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 12, offset: const Offset(0, -4))]),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Total Bayar', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text('Rp ${_fmt(_total)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
      ]),
      const Spacer(),
      SizedBox(width: 170, height: 48,
        child: ElevatedButton(
          onPressed: (_loading || _selected == null) ? null : _booking,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('⛺ Booking Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ]),
  );

  Widget _tagChip(String t) => Container(
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