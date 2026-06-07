// ══ PeralatanModel ═════════════════════════════════════════════
class PeralatanModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final int hargaSewaDerHari;
  final int totalStok;
  final int stokTersedia;
 
  const PeralatanModel({
    required this.id, required this.nama, this.deskripsi,
    required this.hargaSewaDerHari,
    required this.totalStok, required this.stokTersedia,
  });
 
  factory PeralatanModel.fromJson(Map<String, dynamic> j) => PeralatanModel(
    id: j['id'], nama: j['nama'] ?? '',
    deskripsi: j['deskripsi'],
    hargaSewaDerHari: j['harga_sewa_per_hari'] ?? 0,
    totalStok: j['total_stok'] ?? 0,
    stokTersedia: j['stok_tersedia'] ?? 0,
  );
}
 