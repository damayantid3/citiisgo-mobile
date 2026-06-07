// ══ PenginapanModel ════════════════════════════════════════════
import 'kamar_model.dart';

class PenginapanModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? alamat;
  final List<KamarModel> kamar;
 
  const PenginapanModel({required this.id, required this.nama, this.deskripsi, this.alamat, this.kamar = const []});
 
  factory PenginapanModel.fromJson(Map<String, dynamic> j) => PenginapanModel(
    id: j['id'], nama: j['nama'] ?? '',
    deskripsi: j['deskripsi'], alamat: j['alamat'],
    kamar: (j['kamar'] as List? ?? []).map((k) => KamarModel.fromJson(k)).toList(),
  );
}
 