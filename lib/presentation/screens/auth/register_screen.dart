import 'package:flutter/material.dart';

import '../../../core/config/app_colors.dart';

import 'package:citiisgo_mob/data/repositories/auth_repository.dart';

import '../home/home_screen.dart';



class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});

  @override

  State<RegisterScreen> createState() => _RegisterScreenState();

}



class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey    = GlobalKey<FormState>();

  final _namaCtrl   = TextEditingController();

  final _emailCtrl  = TextEditingController();

  final _hpCtrl     = TextEditingController();

  final _passCtrl   = TextEditingController();

  final _confCtrl   = TextEditingController();

  bool _obscureP = true, _obscureC = true, _loading = false, _agree = false;



  @override

  void dispose() {

    for (var c in [_namaCtrl,_emailCtrl,_hpCtrl,_passCtrl,_confCtrl]) c.dispose();

    super.dispose();

  }



  Future<void> _register() async {

    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(

        content: Text('Harap setujui syarat & ketentuan'),

        backgroundColor: AppColors.warning,

        behavior: SnackBarBehavior.floating,

      ));

      return;

    }

    setState(() => _loading = true);

    final result = await AuthRepository().register({

      'nama': _namaCtrl.text.trim(),

      'email': _emailCtrl.text.trim(),

      'no_hp': _hpCtrl.text.trim(),

      'password': _passCtrl.text,

      'password_confirmation': _confCtrl.text,

    });

    if (!mounted) return;

    setState(() => _loading = false);

    if (result['success'] == true) {

      Navigator.pushAndRemoveUntil(context,

        MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(

        content: Text(result['message'] ?? 'Registrasi gagal'),

        backgroundColor: AppColors.danger,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      ));

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Column(

        children: [

          // Header

          Container(

            decoration: const BoxDecoration(

              gradient: AppColors.heroGradient,

              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),

            ),

            child: SafeArea(

              bottom: false,

              child: Padding(

                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),

                child: Row(

                  children: [

                    GestureDetector(

                      onTap: () => Navigator.pop(context),

                      child: Container(

                        width: 36, height: 36,

                        decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(10)),

                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),

                      ),

                    ),

                    const SizedBox(width: 14),

                    Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text('Daftar Akun Baru',

                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),

                        Text('Bergabung dengan CitiisGo sekarang',

                          style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),

                      ],

                    ),

                  ],

                ),

              ),

            ),

          ),



          // Form

          Expanded(

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Form(

                key: _formKey,

                child: Column(

                  children: [

                    _buildField(_namaCtrl, '👤', 'Nama Lengkap', 'Masukkan nama lengkap Anda',

                      validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null),

                    const SizedBox(height: 12),

                    _buildField(_emailCtrl, '📧', 'Email', 'Alamat email aktif',

                      type: TextInputType.emailAddress,

                      validator: (v) {

                        if (v!.isEmpty) return 'Email tidak boleh kosong';

                        if (!v.contains('@')) return 'Format email tidak valid';

                        return null;

                      }),

                    const SizedBox(height: 12),

                    _buildField(_hpCtrl, '📱', 'No. HP (Opsional)', '08xx-xxxx-xxxx',

                      type: TextInputType.phone),

                    const SizedBox(height: 12),

                    _buildPasswordField(_passCtrl, '🔒', 'Password', 'Minimal 8 karakter',

                      _obscureP, () => setState(() => _obscureP = !_obscureP),

                      validator: (v) {

                        if (v!.isEmpty) return 'Password tidak boleh kosong';

                        if (v.length < 8) return 'Password minimal 8 karakter';

                        return null;

                      }),

                    const SizedBox(height: 12),

                    _buildPasswordField(_confCtrl, '🔐', 'Konfirmasi Password', 'Ulangi password Anda',

                      _obscureC, () => setState(() => _obscureC = !_obscureC),

                      validator: (v) {

                        if (v!.isEmpty) return 'Konfirmasi password diperlukan';

                        if (v != _passCtrl.text) return 'Password tidak cocok';

                        return null;

                      }),

                    const SizedBox(height: 16),



                    // Password strength indicator

                    _buildPasswordStrength(),

                    const SizedBox(height: 16),



                    // Agree terms

                    GestureDetector(

                      onTap: () => setState(() => _agree = !_agree),

                      child: Container(

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color: _agree ? AppColors.lightGreen : AppColors.background,

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(color: _agree ? AppColors.primaryGreen : AppColors.borderColor),

                        ),

                        child: Row(

                          children: [

                            Container(

                              width: 20, height: 20,

                              decoration: BoxDecoration(

                                color: _agree ? AppColors.primaryGreen : Colors.white,

                                borderRadius: BorderRadius.circular(5),

                                border: Border.all(color: _agree ? AppColors.primaryGreen : AppColors.borderColor),

                              ),

                              child: _agree ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,

                            ),

                            const SizedBox(width: 10),

                            Expanded(

                              child: RichText(

                                text: TextSpan(

                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),

                                  children: [

                                    const TextSpan(text: 'Saya menyetujui '),

                                    TextSpan(text: 'Syarat & Ketentuan',

                                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),

                                    const TextSpan(text: ' dan '),

                                    TextSpan(text: 'Kebijakan Privasi',

                                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),

                                    const TextSpan(text: ' CitiisGo.'),

                                  ],

                                ),

                              ),

                            ),

                          ],

                        ),

                      ),

                    ),

                    const SizedBox(height: 22),



                    SizedBox(

                      width: double.infinity, height: 50,

                      child: ElevatedButton(

                        onPressed: _loading ? null : _register,

                        style: ElevatedButton.styleFrom(

                          backgroundColor: AppColors.primaryGreen,

                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

                        ),

                        child: _loading

                          ? const SizedBox(width: 22, height: 22,

                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))

                          : const Text(' Daftar Sekarang',

                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),

                      ),

                    ),

                    const SizedBox(height: 16),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                      Text('Sudah punya akun? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                      GestureDetector(

                        onTap: () => Navigator.pop(context),

                        child: const Text('Masuk di sini', style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),

                      ),

                    ]),

                    const SizedBox(height: 16),

                  ],

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildPasswordStrength() {

    final pass = _passCtrl.text;

    int strength = 0;

    if (pass.length >= 8) strength++;

    if (pass.contains(RegExp(r'[A-Z]'))) strength++;

    if (pass.contains(RegExp(r'[0-9]'))) strength++;

    if (pass.contains(RegExp(r'[!@#\$%^&*]'))) strength++;

    final labels = ['', 'Lemah', 'Cukup', 'Kuat', 'Sangat Kuat'];

    final colors = [Colors.transparent, AppColors.danger, AppColors.warning, AppColors.primaryOrange, AppColors.success];

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(children: List.generate(4, (i) => Expanded(

          child: Container(

            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),

            height: 4,

            decoration: BoxDecoration(

              color: i < strength ? colors[strength] : AppColors.borderColor,

              borderRadius: BorderRadius.circular(2),

            ),

          ),

        ))),

        if (pass.isNotEmpty) Padding(

          padding: const EdgeInsets.only(top: 4),

          child: Text('Kekuatan: ${labels[strength]}',

            style: TextStyle(fontSize: 11, color: colors[strength], fontWeight: FontWeight.w600)),

        ),

      ],

    );

  }



  Widget _buildField(TextEditingController ctrl, String emoji, String label, String hint,

    {TextInputType? type, String? Function(String?)? validator}) => Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),

      const SizedBox(height: 5),

      TextFormField(

        controller: ctrl,

        keyboardType: type,

        validator: validator,

        style: const TextStyle(fontSize: 14),

        decoration: InputDecoration(

          prefixIcon: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Text(emoji, style: const TextStyle(fontSize: 18))),

          prefixIconConstraints: const BoxConstraints(minWidth: 44),

          hintText: hint,

          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),

          filled: true, fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderColor)),

          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderColor)),

          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),

          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),

          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        ),

      ),

    ],

  );



  Widget _buildPasswordField(TextEditingController ctrl, String emoji, String label, String hint,

    bool obscure, VoidCallback toggle, {String? Function(String?)? validator}) => Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),

      const SizedBox(height: 5),

      TextFormField(

        controller: ctrl,

        obscureText: obscure,

        validator: validator,

        onChanged: (_) => setState(() {}),

        style: const TextStyle(fontSize: 14),

        decoration: InputDecoration(

          prefixIcon: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Text(emoji, style: const TextStyle(fontSize: 18))),

          prefixIconConstraints: const BoxConstraints(minWidth: 44),

          hintText: hint,

          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),

          suffixIcon: IconButton(

            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,

              color: AppColors.textMuted, size: 20),

            onPressed: toggle),

          filled: true, fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderColor)),

          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderColor)),

          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),

          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),

          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        ),

      ),

    ],

  );

} 

