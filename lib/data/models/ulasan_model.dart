class UlasanModel {
  final int id;
  final int wisataId;
  final String namaUser;
  final double rating;
  final String komentar;
  final DateTime tanggal;

  UlasanModel({
    required this.id,
    required this.wisataId,
    required this.namaUser,
    required this.rating,
    required this.komentar,
    required this.tanggal,
  });

  factory UlasanModel.fromJson(Map<String, dynamic> json) => UlasanModel(
    id: json['id'],
    wisataId: json['wisata_id'],
    namaUser: json['nama_user'],
    rating: (json['rating'] as num).toDouble(),
    komentar: json['komentar'],
    tanggal: DateTime.parse(json['tanggal']),
  );
}