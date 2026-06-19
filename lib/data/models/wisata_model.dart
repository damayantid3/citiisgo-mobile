import 'fasilitas_model.dart';
import 'galeri_model.dart';
import 'kategori_model.dart';

class WisataModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String alamat;
  final double? latitude;
  final double? longitude;
  final int hargaTiket;
  final int kuotaHarian;
  final String status;
  final double rating;
  final String? cover;
  final KategoriModel? kategori;
  final List<GaleriModel> galeri;
  final List<FasilitasModel> fasilitas;

  String? emoji;
  String? kecamatan;
  String? lokasi;
  int? jumlahUlasan;
  int? jumlahKunjungan;
  int? kuotaPerHari;
  bool? adaCamping;
  bool? adaPenginapan;
  bool? adaSewaAlat;
  double? jarakKm;
  String? tag;
 
  WisataModel({
    required this.id, required this.nama, required this.deskripsi,
    required this.alamat, this.latitude, this.longitude,
    required this.hargaTiket, required this.kuotaHarian,
    required this.status, required this.rating,
    this.cover, this.kategori,
    this.galeri = const [], this.fasilitas = const [],
    this.emoji, this.kecamatan, this.lokasi, this.jumlahUlasan,
    this.jumlahKunjungan, this.kuotaPerHari, this.adaCamping,
    this.adaPenginapan, this.adaSewaAlat, this.jarakKm, this.tag,
  });
 
  factory WisataModel.fromJson(Map<String, dynamic> j) {
    final idVal = j['id'] ?? 0;
    final nameVal = j['nama'] ?? '';
    final catNameVal = j['kategori'] != null ? j['kategori']['nama']?.toString() : null;
    final double rawJarak = (j['jarak_km'] as num?)?.toDouble() ?? 0.0;

    return WisataModel(
      id: idVal,
      nama: nameVal,
      deskripsi: j['deskripsi'] ?? '',
      alamat: j['alamat'] ?? '',
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      hargaTiket: _safeInt(j['harga_tiket']),
      kuotaHarian: _safeInt(j['kuota_harian']),
      status: j['status'] ?? 'active',
      rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
      cover: j['cover'],
      kategori: j['kategori'] != null ? KategoriModel.fromJson(j['kategori']) : null,
      galeri: (j['galeri'] as List? ?? []).map((g) => GaleriModel.fromJson(g)).toList(),
      fasilitas: (j['fasilitas'] as List? ?? []).map((f) => FasilitasModel.fromJson(f)).toList(),
      emoji: j['emoji'] ?? _determineEmoji(nameVal, catNameVal),
      kecamatan: j['kecamatan'] ?? 'Tasikmalaya',
      lokasi: j['lokasi'] ?? 'Tasikmalaya',
      jumlahUlasan: j['jumlah_ulasan'] ?? 0,
      jumlahKunjungan: j['jumlah_kunjungan'] ?? 0,
      kuotaPerHari: j['kuota_per_hari'] ?? 0,
      adaCamping: j['ada_camping'] == 1 || j['ada_camping'] == true || (j['id'] != null), // All wisata in seed have camping / facilities
      adaPenginapan: j['ada_penginapan'] == 1 || j['ada_penginapan'] == true || (j['id'] != null),
      adaSewaAlat: j['ada_sewa_alat'] == 1 || j['ada_sewa_alat'] == true || (j['id'] != null),
      jarakKm: _determineDistance(idVal, rawJarak),
      tag: j['tag'] ?? (idVal % 2 == 0 ? 'Populer' : 'Trending'),
    );
  }

  static String _determineEmoji(String nama, String? kategoriNama) {
    final n = nama.toLowerCase();
    final k = (kategoriNama ?? '').toLowerCase();
    if (n.contains('curug') || n.contains('air terjun') || n.contains('waterfall') || n.contains('situ') || n.contains('danau')) {
      return '💧';
    }
    if (n.contains('pantai') || n.contains('beach') || k.contains('pantai') || k.contains('sea')) {
      return '🌊';
    }
    if (n.contains('kampung') || n.contains('budaya') || n.contains('naga') || k.contains('budaya')) {
      return '🏛️';
    }
    return '🌋'; // default to volcano for mountain/other nature
  }

  static double _determineDistance(int id, double rawJarak) {
    if (rawJarak > 0) return rawJarak;
    return 1.5 + (id % 5) * 1.3;
  }
}

int _safeInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.round();
  return (double.tryParse(val.toString()) ?? 0.0).round();
}