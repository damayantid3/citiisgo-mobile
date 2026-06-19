// ══ PaketCampingModel ══════════════════════════════════════════
import 'wisata_model.dart';

class PaketCampingModel {
  final int id;
  final String namaPaket;
  final String? deskripsi;
  final int hargaPerMalam;
  final int kapasitasTamu;
  final int totalSlot;
  final bool tersedia;
  final WisataModel? wisata;
 
  String get nama => namaPaket;
  int get maxTamu => kapasitasTamu;
 
  const PaketCampingModel({
    required this.id, required this.namaPaket, this.deskripsi,
    required this.hargaPerMalam, required this.kapasitasTamu,
    required this.totalSlot, required this.tersedia, this.wisata,
  });
 
  factory PaketCampingModel.fromJson(Map<String, dynamic> j) => PaketCampingModel(
    id: j['id'] ?? 0, namaPaket: j['nama_paket'] ?? '',
    deskripsi: j['deskripsi'],
    hargaPerMalam: _safeInt(j['harga_per_malam']),
    kapasitasTamu: _safeInt(j['kapasitas_tamu']),
    totalSlot: _safeInt(j['total_slot']),
    tersedia: _safeBool(j['tersedia']),
    wisata: j['wisata'] != null ? WisataModel.fromJson(j['wisata']) : null,
  );

  static List<PaketCampingModel> dummyList() => [
    const PaketCampingModel(
      id: 1,
      namaPaket: 'Paket Hemat',
      deskripsi: 'Tenda standar, tempat tidur bersama, dan fasilitas dasar.',
      hargaPerMalam: 175000,
      kapasitasTamu: 4,
      totalSlot: 10,
      tersedia: true,
    ),
    const PaketCampingModel(
      id: 2,
      namaPaket: 'Paket Keluarga',
      deskripsi: 'Tenda keluarga, sarapan, dan area bermain anak.',
      hargaPerMalam: 250000,
      kapasitasTamu: 6,
      totalSlot: 5,
      tersedia: true,
    ),
    const PaketCampingModel(
      id: 3,
      namaPaket: 'Paket Premium',
      deskripsi: 'Tenda besar, kasur empuk, dan layanan tambahan.',
      hargaPerMalam: 375000,
      kapasitasTamu: 8,
      totalSlot: 3,
      tersedia: true,
    ),
  ];
}

int _safeInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.round();
  return (double.tryParse(val.toString()) ?? 0.0).round();
}

bool _safeBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is int) return val == 1;
  if (val is String) {
    return val == '1' || val.toLowerCase() == 'true';
  }
  return false;
}
