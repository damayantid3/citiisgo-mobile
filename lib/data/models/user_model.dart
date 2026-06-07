// ══ UserModel ═════════════════════════════════════════════════
class UserModel {
  final int id;
  final String nama;
  final String email;
  final String? noHp;
  final String? fotoProfil;
  final String? token;
  final String role;
  final String status;
 
  const UserModel({
    required this.id, required this.nama, required this.email,
    this.noHp, this.fotoProfil, this.token,
    required this.role, required this.status,
  });
 
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], nama: j['nama'], email: j['email'],
    noHp: j['no_hp'], fotoProfil: j['foto_profil'], token: j['token'],
    role: j['role'] ?? 'user', status: j['status'] ?? 'active',
  );
 
  Map<String, dynamic> toJson() => {
    'id':id,'nama':nama,'email':email,'no_hp':noHp,
    'foto_profil':fotoProfil,'token':token,'role':role,'status':status,
  };
}