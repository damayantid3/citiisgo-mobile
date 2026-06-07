// ══ FasilitasModel ═════════════════════════════════════════════
class FasilitasModel {
  final int id;
  final String nama;
  final String? ikon;
  final bool tersedia;
 
  const FasilitasModel({required this.id, required this.nama, this.ikon, required this.tersedia});
 
  factory FasilitasModel.fromJson(Map<String, dynamic> j) => FasilitasModel(
    id: j['id'], nama: j['nama'] ?? '', ikon: j['ikon'], tersedia: j['tersedia'] ?? true,
  );
}
 