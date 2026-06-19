// ══ PeralatanModel ═════════════════════════════════════════════
class PeralatanModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final int hargaSewaPerHari;
  final int totalStok;
  final int stokTersedia;
 
  const PeralatanModel({
    required this.id, required this.nama, this.deskripsi,
    required this.hargaSewaPerHari,
    required this.totalStok, required this.stokTersedia,
  });
 
  factory PeralatanModel.fromJson(Map<String, dynamic> j) => PeralatanModel(
    id: j['id'] ?? 0, nama: j['nama'] ?? '',
    deskripsi: j['deskripsi'],
    hargaSewaPerHari: _safeInt(j['harga_sewa_per_hari']),
    totalStok: _safeInt(j['total_stok']),
    stokTersedia: _safeInt(j['stok_tersedia']),
  );
}

int _safeInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.round();
  return (double.tryParse(val.toString()) ?? 0.0).round();
}
 