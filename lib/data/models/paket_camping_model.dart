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
    id: j['id'], namaPaket: j['nama_paket'] ?? '',
    deskripsi: j['deskripsi'],
    hargaPerMalam: j['harga_per_malam'] ?? 0,
    kapasitasTamu: j['kapasitas_tamu'] ?? 0,
    totalSlot: j['total_slot'] ?? 0,
    tersedia: j['tersedia'] ?? true,
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
