// ══ WisataModel ════════════════════════════════════════════════
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
  });
 
  factory WisataModel.fromJson(Map<String, dynamic> j) => WisataModel(
    id: j['id'], nama: j['nama'] ?? '', deskripsi: j['deskripsi'] ?? '',
    alamat: j['alamat'] ?? '',
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    hargaTiket: j['harga_tiket'] ?? 0,
    kuotaHarian: j['kuota_harian'] ?? 0,
    status: j['status'] ?? 'active',
    rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
    cover: j['cover'],
    kategori: j['kategori'] != null ? KategoriModel.fromJson(j['kategori']) : null,
    galeri: (j['galeri'] as List? ?? []).map((g) => GaleriModel.fromJson(g)).toList(),
    fasilitas: (j['fasilitas'] as List? ?? []).map((f) => FasilitasModel.fromJson(f)).toList(),
  );
}
