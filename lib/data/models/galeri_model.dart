// ══ GaleriModel ════════════════════════════════════════════════
class GaleriModel {
  final int id;
  final String url;
  final bool isCover;
  final String? keterangan;
 
  const GaleriModel({required this.id, required this.url, required this.isCover, this.keterangan});
 
  factory GaleriModel.fromJson(Map<String, dynamic> j) => GaleriModel(
    id: j['id'], url: j['url'] ?? '', isCover: j['is_cover'] ?? false, keterangan: j['keterangan'],
  );
}