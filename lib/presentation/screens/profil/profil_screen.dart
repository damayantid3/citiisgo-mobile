import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/booking_provider.dart'; // ✅ Statistik dari API
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

  static const colorPrimary  = Color(0xFF0F7133);
  static const colorOrange   = Color(0xFFFF7A00);
  static const colorSlate900 = Color(0xFF0F172A);
  static const colorSlate500 = Color(0xFF64748B);
  static const colorSlate100 = Color(0xFFF1F5F9);
  static const colorSlate200 = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadUser();
    // ✅ Load riwayat dari API untuk statistik profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadRiwayat();
    });
  }

  Future<void> _loadUser() async {
    final u = await _authRepo.getLocalUser();
    if (mounted) setState(() { _user = u; _loading = false; });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text('Keluar dari CitiisGo?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, fontSize: 18,
              color: colorSlate900,
            )),
        content: Text(
          'Sesi aktif Anda akan dihapus. Anda perlu masuk kembali untuk mengelola pesanan wisata.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: colorSlate500,
            fontWeight: FontWeight.w500, height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: colorSlate500, fontWeight: FontWeight.w700,
                )),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text('Ya, Keluar',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authRepo.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                    color: colorSlate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Perbarui Profil Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: colorSlate900,
                  )),
              const SizedBox(height: 20),
              _inputField(Icons.person_rounded, 'Nama Lengkap', namaCtrl),
              const SizedBox(height: 16),
              _inputField(Icons.phone_android_rounded, 'Nomor Handphone',
                  hpCtrl, type: TextInputType.phone),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final r = await _authRepo.updateProfile(
                      {'nama': namaCtrl.text, 'no_hp': hpCtrl.text},
                    );
                    if (!mounted) return;
                    if (r['success'] == true) {
                      setState(() => _user = r['user']);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profil berhasil diperbarui',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            )),
                        backgroundColor: colorPrimary,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Simpan Perubahan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: colorPrimary),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader()),
                // ✅ Statistik dari BookingProvider (API nyata)
                SliverToBoxAdapter(child: _buildStatistikApi()),
                SliverToBoxAdapter(child: _buildMenuSection()),
              ],
            ),
    );
  }

  Widget _buildHeroHeader() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF064E3B), colorPrimary],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profil Saya',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3,
                        )),
                    GestureDetector(
                      onTap: _showEditProfil,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text('Edit',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: colorOrange,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 16, offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _user?.nama.isNotEmpty == true
                              ? _user!.nama[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                        color: colorOrange, shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(_user?.nama ?? 'Wisatawan',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, letterSpacing: -0.2,
                    )),
                const SizedBox(height: 4),
                Text(_user?.email ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(.7), fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _user?.role == 'pengelola'
                        ? '🏔️ Pengelola Wisata'
                        : _user?.role == 'admin'
                            ? '⚡ Administrator'
                            : '🎒 Anggota Wisatawan',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ✅ Statistik dari BookingProvider (API nyata — bukan angka hardcode)
  Widget _buildStatistikApi() => Consumer<BookingProvider>(
        builder: (_, bookingP, __) {
          if (bookingP.isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: colorPrimary, strokeWidth: 2,
                ),
              ),
            );
          }

          final semua     = bookingP.riwayat.length;
          final selesai   = bookingP.riwayat
              .where((r) => r['status'] == 'Lunas' || r['status'] == 'Selesai')
              .length;
          final menunggu  = bookingP.riwayat
              .where((r) =>
                  r['status'] == 'Belum Dibayar' ||
                  r['status'] == 'Terkonfirmasi')
              .length;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(.04),
                    blurRadius: 24, offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  _statItem('$semua', 'Total Trip', colorPrimary),
                  _vDiv(),
                  _statItem('$selesai', 'Selesai', colorOrange),
                  _vDiv(),
                  _statItem('$menunggu', 'Aktif', AppColors.info),
                  _vDiv(),
                  _statItem(
                    '${bookingP.countByTipe('Sewa Camp')}',
                    'Camp Trip',
                    const Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildMenuSection() => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _menuSection('AKTIVITAS AKUN', [
              _menuItem(Icons.receipt_long_rounded, 'Riwayat Transaksi',
                  'Kelola seluruh pesanan tiket & sewa', colorPrimary, () {}),
              _menuItem(Icons.notifications_active_rounded, 'Pemberitahuan',
                  'Lihat pesan masuk terbaru', colorOrange, () {}),
              _menuItem(Icons.star_rate_rounded, 'Ulasan Saya',
                  'Komentar destinasi pariwisata', const Color(0xFFEAB308),
                  () {}),
              _menuItem(Icons.bookmark_rounded, 'Destinasi Favorit',
                  'Lokasi camping pilihan tersimpan', Colors.redAccent, () {}),
            ]),
            const SizedBox(height: 16),
            _menuSection('KEAMANAN & PRIVASI', [
              _menuItem(Icons.lock_rounded, 'Ubah Password Akun',
                  'Perbarui kata sandi berkala', AppColors.info,
                  () => _showUbahPassword()),
              _menuItem(Icons.g_translate_rounded, 'Bahasa Aplikasi',
                  'Indonesia (ID)', const Color(0xFF16A34A), () {}),
              _menuItem(Icons.help_center_rounded, 'Pusat Bantuan & FAQ',
                  'Solusi kendala aplikasi', const Color(0xFF9333EA), () {}),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorSlate200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: colorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.layers_rounded,
                          color: colorPrimary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CitiisGo Mobile',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800, fontSize: 14,
                            color: colorSlate900,
                          )),
                      Text('Versi 1.0.0 (Stable)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, color: colorSlate500,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Up to date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: colorPrimary,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.power_settings_new_rounded,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Text('Keluar dari Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5, fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('© 2026 CitiisGo · Made for Tasikmalaya Adventure',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: colorSlate500, fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 24),
          ],
        ),
      );

  Widget _statItem(String val, String lbl, Color color) => Expanded(
        child: Column(
          children: [
            Text(val,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color,
                )),
            const SizedBox(height: 4),
            Text(lbl,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: colorSlate500,
                  fontWeight: FontWeight.w600, height: 1.3,
                )),
          ],
        ),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 32, color: colorSlate200);

  Widget _menuSection(String title, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, fontWeight: FontWeight.w800,
                  color: colorSlate500, letterSpacing: 0.6,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(.02),
                  blurRadius: 16, offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((e) => Column(
                    children: [
                      e.value,
                      if (e.key < items.length - 1)
                        const Divider(
                          height: 1, indent: 64, color: colorSlate100,
                        ),
                    ],
                  )).toList(),
            ),
          ),
        ],
      );

  Widget _menuItem(IconData icon, String title, String subtitle, Color color,
          VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, color: color, size: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: colorSlate900,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: colorSlate500,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: colorSlate500, size: 14),
            ],
          ),
        ),
      );

  Widget _inputField(
    IconData icon, String label, TextEditingController ctrl, {
    TextInputType? type,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5, fontWeight: FontWeight.w700,
                color: colorSlate500,
              )),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl, keyboardType: type,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w700, color: colorSlate900,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: colorSlate500, size: 18),
              filled: true, fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: colorSlate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: colorSlate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: colorPrimary, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14,
              ),
            ),
          ),
        ],
      );

  void _showUbahPassword() {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                    color: colorSlate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Perbarui Keamanan Akun',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: colorSlate900,
                  )),
              const SizedBox(height: 20),
              _inputField(
                  Icons.lock_open_rounded, 'Kata Sandi Lama', oldCtrl),
              const SizedBox(height: 14),
              _inputField(Icons.lock_outline, 'Kata Sandi Baru', newCtrl),
              const SizedBox(height: 14),
              _inputField(Icons.gpp_good_rounded,
                  'Konfirmasi Kata Sandi Baru', confCtrl),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Sandi berhasil diperbarui',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          )),
                      backgroundColor: colorPrimary,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Perbarui Password',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}