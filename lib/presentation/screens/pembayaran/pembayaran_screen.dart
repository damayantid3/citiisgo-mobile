import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../riwayat/riwayat_screen.dart';

// ══════════════════════════════════════════════════════════════
// PEMBAYARAN SCREEN
// ══════════════════════════════════════════════════════════════
class PembayaranScreen extends StatefulWidget {
  final String paymentUrl;
  final String kodeBooking;
  final int totalHarga;
  final String layanan;

  const PembayaranScreen({
    super.key,
    required this.paymentUrl,
    required this.kodeBooking,
    required this.totalHarga,
    required this.layanan,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  int _selectedMethod = 0;
  bool _loading = false;

  final List<Map<String, dynamic>> _methods = [
    {'icon': '🏦', 'name': 'Transfer Bank', 'desc': 'BCA, BRI, BNI, Mandiri', 'fee': 0},
    {'icon': '📱', 'name': 'QRIS', 'desc': 'Scan QR dengan app apapun', 'fee': 0},
    {'icon': '💚', 'name': 'GoPay', 'desc': 'Bayar dengan saldo GoPay', 'fee': 0},
    {'icon': '🟣', 'name': 'OVO', 'desc': 'Bayar dengan saldo OVO', 'fee': 0},
    {'icon': '🔵', 'name': 'Dana', 'desc': 'Bayar dengan saldo Dana', 'fee': 0},
    {'icon': '💳', 'name': 'Kartu Kredit/Debit', 'desc': 'Visa, Mastercard, JCB', 'fee': 2000},
  ];

  Future<void> _bayar() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => PembayaranSuccessScreen(
        kodeBooking: widget.kodeBooking,
        totalHarga: widget.totalHarga,
        layanan: widget.layanan,
        metode: _methods[_selectedMethod]['name'],
      ),
    ));
  }

  int get _totalWithFee => widget.totalHarga + (_methods[_selectedMethod]['fee'] as int);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  Text('💳 Pembayaran', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('Selesaikan pembayaran Anda', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.lock_outline_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('Aman', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),
              // Order summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(widget.layanan, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('Rp ${_fmtHarga(widget.totalHarga)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Kode Booking', style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 11.5)),
                    Text(widget.kodeBooking, style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
            ]),
          )),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Timer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCC02))),
                child: const Row(children: [
                  Text('⏰', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bayar sebelum: 23:59:00', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFFE65100))),
                    Text('Pesanan akan otomatis dibatalkan jika tidak dibayar', style: TextStyle(fontSize: 11, color: Color(0xFFF57F17))),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),

              // Metode pembayaran
              const Align(alignment: Alignment.centerLeft,
                child: Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),

              ..._methods.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final isSelected = _selectedMethod == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMethod = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderColor, width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightGreen : AppColors.background,
                          borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(m['icon'], style: const TextStyle(fontSize: 20)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text(m['desc'], style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        if ((m['fee'] as int) > 0)
                          Text('+Rp ${_fmtHarga(m['fee'])}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted))
                        else
                          const Text('Gratis', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderColor, width: 2),
                            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                          ),
                          child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
                        ),
                      ]),
                    ]),
                  ),
                );
              }).toList(),

              const SizedBox(height: 14),
              // Total & rincian
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                child: Column(children: [
                  _sumRow('Subtotal', 'Rp ${_fmtHarga(widget.totalHarga)}'),
                  _sumRow('Biaya layanan', _methods[_selectedMethod]['fee'] == 0 ? 'Gratis' : '+Rp ${_fmtHarga(_methods[_selectedMethod]['fee'])}'),
                  const Divider(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Rp ${_fmtHarga(_totalWithFee)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primaryGreen)),
                  ]),
                ]),
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ),

        // Bottom
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 12, offset: const Offset(0, -4))]),
          child: Column(children: [
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _bayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('💳 Bayar Rp ${_fmtHarga(_totalWithFee)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              )),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.security_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('Pembayaran diproses secara aman oleh Midtrans', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _sumRow(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    ]),
  );

  String _fmtHarga(int h) {
    if (h >= 1000000) return '${(h / 1e6).toStringAsFixed(1)}jt';
    if (h >= 1000) {
      final s = h.toString();
      final result = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if ((s.length - i) % 3 == 0 && i != 0) result.write('.');
        result.write(s[i]);
      }
      return result.toString();
    }
    return h.toString();
  }
}

// ══════════════════════════════════════════════════════════════
// PEMBAYARAN SUCCESS SCREEN
// ══════════════════════════════════════════════════════════════
class PembayaranSuccessScreen extends StatefulWidget {
  final String kodeBooking;
  final int totalHarga;
  final String layanan;
  final String metode;

  const PembayaranSuccessScreen({
    super.key,
    required this.kodeBooking,
    required this.totalHarga,
    required this.layanan,
    required this.metode,
  });

  @override
  State<PembayaranSuccessScreen> createState() => _PembayaranSuccessScreenState();
}

class _PembayaranSuccessScreenState extends State<PembayaranSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 300), () => _ctrl.forward());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            // Success icon
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x401A6B2A), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 28),

            FadeTransition(
              opacity: _fade,
              child: Column(children: [
                const Text('Pembayaran Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('${widget.layanan} Anda telah dikonfirmasi.',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
                const SizedBox(height: 28),

                // Ticket card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 20)],
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Kode Booking', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(widget.kodeBooking,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('✅ LUNAS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ]),
                    ),
                    // Dashed separator
                    Row(children: [
                      Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.borderColor))),
                      Expanded(child: LayoutBuilder(builder: (_, c) => Row(
                        children: List.generate((c.maxWidth / 8).floor(), (_) => Container(width: 4, height: 1, margin: const EdgeInsets.symmetric(horizontal: 2), color: AppColors.borderColor)),
                      ))),
                      Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.borderColor))),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        _ticketRow('Layanan', widget.layanan),
                        _ticketRow('Metode Bayar', widget.metode),
                        _ticketRow('Tanggal', _formatNow()),
                        const Divider(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total Dibayar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          Text('Rp ${_fmtHarga(widget.totalHarga)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryGreen)),
                        ]),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Text('📧', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(child: Text('E-tiket & konfirmasi telah dikirim ke email Anda. Tunjukkan kode booking saat tiba.',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, height: 1.5))),
                  ]),
                ),
              ]),
            ),

            const Spacer(),
            Column(children: [
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const RiwayatScreen()), (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('📋 Lihat Riwayat Booking', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
                )),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('🏠 Kembali ke Beranda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _ticketRow(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    ]),
  );

  String _fmtHarga(int h) {
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatNow() {
    final now = DateTime.now();
    final bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${now.day} ${bulan[now.month]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}