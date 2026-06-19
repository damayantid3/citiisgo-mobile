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
    id: j['id'] ?? 0, tipeKamar: j['tipe_kamar'] ?? '',
    deskripsi: j['deskripsi'],
    kapasitas: _safeInt(j['kapasitas']),
    hargaPerMalam: _safeInt(j['harga_per_malam']),
    totalKamar: _safeInt(j['total_kamar']),
    tersedia: _safeBool(j['tersedia']),
  );
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
 