
// ══ KategoriModel ══════════════════════════════════════════════
class KategoriModel {
  final int id;
  final String nama;
  final String? ikon;
  final int? wisataCount;
 
  const KategoriModel({required this.id, required this.nama, this.ikon, this.wisataCount});
 
  factory KategoriModel.fromJson(Map<String, dynamic> j) => KategoriModel(
    id: j['id'], nama: j['nama'] ?? '', ikon: j['ikon'],
    wisataCount: j['wisata_count'],
  );
}