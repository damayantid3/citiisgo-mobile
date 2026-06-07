// ══ KamarModel ═════════════════════════════════════════════════
class KamarModel {
  final int id;
  final String tipeKamar;
  final String? deskripsi;
  final int kapasitas;
  final int hargaPerMalam;
  final int totalKamar;
  final bool tersedia;
 
  const KamarModel({
    required this.id, required this.tipeKamar, this.deskripsi,
    required this.kapasitas, required this.hargaPerMalam,
    required this.totalKamar, required this.tersedia,
  });
 
  factory KamarModel.fromJson(Map<String, dynamic> j) => KamarModel(
    id: j['id'], tipeKamar: j['tipe_kamar'] ?? '',
    deskripsi: j['deskripsi'],
    kapasitas: j['kapasitas'] ?? 0,
    hargaPerMalam: j['harga_per_malam'] ?? 0,
    totalKamar: j['total_kamar'] ?? 0,
    tersedia: j['tersedia'] ?? true,
  );
}
 