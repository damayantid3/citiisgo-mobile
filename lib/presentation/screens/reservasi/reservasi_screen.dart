import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/reservasi_model.dart';
import '../../../data/models/wisata_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../pembayaran/pembayaran_screen.dart';

// ══════════════════════════════════════════════════════════════
// RESERVASI TIKET SCREEN
// ══════════════════════════════════════════════════════════════
class ReservasiScreen extends StatefulWidget {
  final WisataModel wisata;
  const ReservasiScreen({super.key, required this.wisata});
  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  final _repo = BookingRepository();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _jumlahTiket = 1;
  bool _loading = false;

  int get _totalHarga => widget.wisata.hargaTiket * _jumlahTiket;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _booking() async {
    setState(() => _loading = true);
    final result = await _repo.createReservasi({
      'wisata_id': widget.wisata.id,
      'tanggal_kunjungan': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}',
      'jumlah_tiket': _jumlahTiket,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PembayaranScreen(
          paymentUrl: result['payment_url'] ?? '',
          kodeBooking: (result['data'] as ReservasiModel).kodeBooking,
          totalHarga: _totalHarga,
          layanan: 'Reservasi Tiket',
        ),
      ));
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg ?? 'Gagal membuat reservasi'),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('🎫 Reservasi Tiket', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                      Text(widget.wisata.nama, style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
                    ])),
                  ]),
                  const SizedBox(height: 14),
                  // Steps indicator
                  Row(children: [
                    _stepBadge('1', 'Detail', true, true),
                    _stepLine(true),
                    _stepBadge('2', 'Bayar', false, false),
                    _stepLine(false),
                    _stepBadge('3', 'Selesai', false, false),
                  ]),
                ]),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Wisata info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(widget.wisata.kategori?.ikon ?? '🏔️', style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.wisata.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('📍 ${widget.wisata.alamat}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('⭐ ${widget.wisata.rating}  ·  🎫 Rp ${_formatHarga(widget.wisata.hargaTiket)}/orang',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 14),

                // Date picker
                _sectionCard('📅 Tanggal Kunjungan', GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(.3)),
                    ),
                    child: Row(children: [
                      const Text('📅', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                        Text(_getDayName(_selectedDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGreen, size: 20),
                    ]),
                  ),
                )),
                const SizedBox(height: 12),

                // Jumlah tiket
                _sectionCard('🎟️ Jumlah Tiket', Row(children: [
                  GestureDetector(
                    onTap: () { if (_jumlahTiket > 1) setState(() => _jumlahTiket--); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _jumlahTiket > 1 ? AppColors.lightGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _jumlahTiket > 1 ? AppColors.primaryGreen : AppColors.borderColor),
                      ),
                      child: Icon(Icons.remove_rounded, color: _jumlahTiket > 1 ? AppColors.primaryGreen : AppColors.textMuted, size: 20),
                    ),
                  ),
                  Expanded(child: Center(
                    child: Text('$_jumlahTiket', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  )),
                  GestureDetector(
                    onTap: () { if (_jumlahTiket < 20) setState(() => _jumlahTiket++); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('× Rp ${_formatHarga(widget.wisata.hargaTiket)}',
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                ])),
                const SizedBox(height: 12),

                // Ringkasan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(children: [
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Ringkasan Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ]),
                    const Divider(height: 16),
                    _summaryRow('Harga tiket', 'Rp ${_formatHarga(widget.wisata.hargaTiket)}'),
                    _summaryRow('Jumlah', '$_jumlahTiket tiket'),
                    _summaryRow('Tanggal kunjungan', _formatDate(_selectedDate)),
                    const Divider(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('Rp ${_formatHarga(_totalHarga)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryGreen)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Row(children: [
                    Text('💡', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(child: Text('Pembayaran akan diproses via Midtrans. Tiket dikirim ke email setelah pembayaran berhasil.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFFF57F17), height: 1.5))),
                  ]),
                ),
              ]),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('Rp ${_formatHarga(_totalHarga)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                ]),
                SizedBox(
                  width: 160, height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _booking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('💳 Bayar Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _stepBadge(String num, String lbl, bool active, bool done) => Expanded(
    child: Column(children: [
      Container(
        width: 28, height: 28, decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active || done ? Colors.white : Colors.white.withOpacity(.3)),
        child: Center(child: done
          ? const Icon(Icons.check_rounded, color: AppColors.primaryGreen, size: 16)
          : Text(num, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              color: active ? AppColors.primaryGreen : Colors.white.withOpacity(.5)))),
      ),
      const SizedBox(height: 3),
      Text(lbl, style: TextStyle(fontSize: 10, color: active ? Colors.white : Colors.white.withOpacity(.5), fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
    ]),
  );

  Widget _stepLine(bool done) => Container(
    height: 2, width: 40,
    margin: const EdgeInsets.only(bottom: 16),
    color: done ? Colors.white : Colors.white.withOpacity(.3),
  );

  Widget _sectionCard(String title, Widget content) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      content,
    ]),
  );

  Widget _summaryRow(String key, String val) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(key, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );

  String _formatHarga(int h) {
    if (h >= 1000000) return '${(h/1000000).toStringAsFixed(1)}jt';
    if (h >= 1000) return '${(h/1000).toStringAsFixed(0)}rb';
    return h.toString();
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')} ${['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'][d.month]} ${d.year}';
  String _getDayName(DateTime d) => ['','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'][d.weekday];
}