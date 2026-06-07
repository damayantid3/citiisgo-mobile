// ══ NotifikasiModel ════════════════════════════════════════════
class NotifikasiModel {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final bool isRead;
  final String createdAt;
 
  const NotifikasiModel({
    required this.id, required this.judul, required this.pesan,
    required this.tipe, required this.isRead, required this.createdAt,
  });
 
  factory NotifikasiModel.fromJson(Map<String, dynamic> j) => NotifikasiModel(
    id: j['id'], judul: j['judul'] ?? '', pesan: j['pesan'] ?? '',
    tipe: j['tipe'] ?? 'info', isRead: j['is_read'] ?? false,
    createdAt: j['created_at'] ?? '',
  );
}
 