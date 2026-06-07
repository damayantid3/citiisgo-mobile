// ══ ReservasiModel ═════════════════════════════════════════════
import 'pembayaran_info.dart';
import 'wisata_model.dart';

class ReservasiModel {
  final int id;
  final String kodeBooking;
  final String tanggalKunjungan;
  final int jumlahTiket;
  final int totalHarga;
  final String status;
  final WisataModel? wisata;
  final PembayaranInfo? pembayaran;
  final String? createdAt;
 
  const ReservasiModel({
    required this.id, required this.kodeBooking,
    required this.tanggalKunjungan, required this.jumlahTiket,
    required this.totalHarga, required this.status,
    this.wisata, this.pembayaran, this.createdAt,
  });
 
  factory ReservasiModel.fromJson(Map<String, dynamic> j) => ReservasiModel(
    id: j['id'], kodeBooking: j['kode_booking'] ?? '',
    tanggalKunjungan: j['tanggal_kunjungan'] ?? '',
    jumlahTiket: j['jumlah_tiket'] ?? 0,
    totalHarga: j['total_harga'] ?? 0,
    status: j['status'] ?? 'pending',
    wisata: j['wisata'] != null ? WisataModel.fromJson(j['wisata']) : null,
    pembayaran: j['pembayaran'] != null ? PembayaranInfo.fromJson(j['pembayaran']) : null,
    createdAt: j['created_at'],
  );
}