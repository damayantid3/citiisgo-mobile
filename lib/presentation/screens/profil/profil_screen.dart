import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _authRepo = AuthRepository();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _authRepo.getLocalUser();
    if (mounted) setState(() { _user = u; _loading = false; });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari CitiisGo?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: const Text('Anda akan keluar dari akun. Data lokal akan dihapus.', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authRepo.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  void _showEditProfil() {
    final namaCtrl = TextEditingController(text: _user?.nama ?? '');
    final hpCtrl   = TextEditingController(text: _user?.noHp ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('✏️ Edit Profil', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            _inputField('👤', 'Nama Lengkap', namaCtrl),
            const SizedBox(height: 12),
            _inputField('📱', 'No. HP', hpCtrl, type: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final r = await _authRepo.updateProfile({'nama': namaCtrl.text, 'no_hp': hpCtrl.text});
                  if (!mounted) return;
                  if (r['success'] == true) {
                    setState(() => _user = r['user']);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('💾 Simpan Perubahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              )),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : CustomScrollView(slivers: [
            // Hero header
            SliverToBoxAdapter(child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: SafeArea(bottom: false, child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('👤 Profil Saya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: _showEditProfil,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [
                          Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Avatar
                  Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryOrange,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 12)],
                      ),
                      child: Center(child: Text(
                        _user?.nama.isNotEmpty == true ? _user!.nama[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                      )),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(_user?.nama ?? 'Wisatawan', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(_user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _user?.role == 'user' ? '🧳 Wisatawan' : _user?.role == 'pengelola' ? '🏔️ Pengelola' : '⚡ Admin',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              )),
            )),

            // Stats
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
                child: Row(children: [
                  _statItem('4', 'Total\nBooking',    AppColors.primaryGreen),
                  _vDiv(),
                  _statItem('3', 'Selesai',           AppColors.primaryOrange),
                  _vDiv(),
                  _statItem('1', 'Menunggu\nBayar',   const Color(0xFF1565C0)),
                  _vDiv(),
                  _statItem('12', 'Ulasan\nDiberikan', const Color(0xFF6A1B9A)),
                ]),
              ),
            )),

            // Menu items
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(children: [
                _menuSection('Akun Saya', [
                  _menuItem('📋', 'Riwayat Booking',    'Lihat semua pesanan',    AppColors.primaryGreen,          () {}),
                  _menuItem('🔔', 'Notifikasi',          'Kelola pemberitahuan',   AppColors.primaryOrange,         () {}),
                  _menuItem('⭐', 'Ulasan Saya',         'Ulasan yang pernah dibuat', const Color(0xFFF9A825),     () {}),
                  _menuItem('📍', 'Wisata Favorit',      'Destinasi tersimpan',    AppColors.danger,               () {}),
                ]),
                const SizedBox(height: 12),
                _menuSection('Pengaturan', [
                  _menuItem('🔒', 'Ubah Password',       'Perbarui keamanan akun',  const Color(0xFF1565C0),       () => _showUbahPassword()),
                  _menuItem('🌐', 'Bahasa',              'Indonesia',               const Color(0xFF388E3C),        () {}),
                  _menuItem('🔔', 'Pengaturan Notif',   'Kelola notifikasi push',  AppColors.primaryOrange,        () {}),
                  _menuItem('❓', 'Bantuan & FAQ',       'Pusat bantuan',           const Color(0xFF6A1B9A),        () {}),
                  _menuItem('📜', 'Syarat & Ketentuan', 'Kebijakan layanan',       AppColors.textMuted,            () {}),
                ]),
                const SizedBox(height: 12),

                // App info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('CitiisGo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('Versi 1.0.0 · Build 2025', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Terbaru', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),

                // Logout button
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                      SizedBox(width: 8),
                      Text('Keluar dari Akun', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.danger)),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                Text('© 2025 CitiisGo · Jelajah • Pesan • Nikmati', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                const SizedBox(height: 16),
              ]),
            )),
          ]),
    );
  }

  Widget _statItem(String val, String lbl, Color color) => Expanded(child: Column(children: [
    Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
    const SizedBox(height: 3),
    Text(lbl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.3)),
  ]));

  Widget _vDiv() => Container(width: 1, height: 36, color: AppColors.borderColor);

  Widget _menuSection(String title, List<Widget> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: .5)),
    ),
    Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
      child: Column(children: items.asMap().entries.map((e) => Column(children: [
        e.value,
        if (e.key < items.length - 1) const Divider(height: 1, indent: 56),
      ])).toList()),
    ),
  ]);

  Widget _menuItem(String emoji, String title, String subtitle, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      ]),
    ),
  );

  Widget _inputField(String emoji, String label, TextEditingController ctrl, {TextInputType? type}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(emoji, style: const TextStyle(fontSize: 18))),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: AppColors.borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: AppColors.borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );

  void _showUbahPassword() {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('🔒 Ubah Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            _inputField('🔑', 'Password Lama', oldCtrl),
            const SizedBox(height: 12),
            _inputField('🔒', 'Password Baru', newCtrl),
            const SizedBox(height: 12),
            _inputField('🔐', 'Konfirmasi Password Baru', confCtrl),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diperbarui'), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('💾 Perbarui Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              )),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}