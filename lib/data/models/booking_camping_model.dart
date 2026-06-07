// ══ BookingCampingModel ════════════════════════════════════════
import 'paket_camping_model.dart';
import 'pembayaran_info.dart';

class BookingCampingModel {
  final int id;
  final String kodeBooking;
  final String tanggalCheckin;
  final String tanggalCheckout;
  final int jumlahTamu;
  final int durasi;
  final int totalHarga;
  final String status;
  final PaketCampingModel? paket;
  final PembayaranInfo? pembayaran;
 
  const BookingCampingModel({
    required this.id, required this.kodeBooking,
    required this.tanggalCheckin, required this.tanggalCheckout,
    required this.jumlahTamu, required this.durasi,
    required this.totalHarga, required this.status,
    this.paket, this.pembayaran,
  });
 
  factory BookingCampingModel.fromJson(Map<String, dynamic> j) => BookingCampingModel(
    id: j['id'], kodeBooking: j['kode_booking'] ?? '',
    tanggalCheckin: j['tanggal_checkin'] ?? '',
    tanggalCheckout: j['tanggal_checkout'] ?? '',
    jumlahTamu: j['jumlah_tamu'] ?? 0,
    durasi: j['durasi'] ?? 0,
    totalHarga: j['total_harga'] ?? 0,
    status: j['status'] ?? 'pending',
    paket: j['paket'] != null ? PaketCampingModel.fromJson(j['paket']) : null,
    pembayaran: j['pembayaran'] != null ? PembayaranInfo.fromJson(j['pembayaran']) : null,
  );
}