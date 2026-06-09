import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure   = true;

  // Palet Warna CitiisGo (Identitas Brand Terjaga)
  static const colorPrimary  = Color(0xFF0F7133); 
  static const colorOrange   = Color(0xFFFF7A00); 
  static const colorSlate900 = Color(0xFF0F172A); 
  static const colorSlate500 = Color(0xFF64748B); 
  static const colorSlate200 = Color(0xFFE2E8F0); 

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(_emailCtrl.text.trim(), _passCtrl.text);
    
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _showSnackBar(authProvider.error ?? 'Login gagal', Colors.redAccent);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();
    
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (authProvider.error != null) {
      _showSnackBar(authProvider.error!, Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), 
      backgroundColor: bg, 
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Tailwind slate-50
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo dengan Animasi Denyut Halus Berbasis State Loading
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: EdgeInsets.all(authLoading ? 16 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorPrimary.withOpacity(authLoading ? 0.15 : 0.06), 
                          blurRadius: 30, 
                          offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/CitiisgoLogo.jpeg', 
                        height: 100, 
                        width: 100, 
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Selamat Datang Kembali',
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: colorSlate900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk mengelola pesanan & destinasi wisata',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: colorSlate500, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Card Form Input (Tailwind Premium shadow-xl)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24), 
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.05), 
                          blurRadius: 32, 
                          offset: const Offset(0, 16)
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: colorSlate900),
                          decoration: _tailwindInput('📧', 'Alamat Email'),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Format email tidak valid' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: colorSlate900),
                          decoration: _inputPasswordDecoration(
                            '🔒', 
                            'Password',
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colorSlate500, size: 18),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Lupa Password?', style: GoogleFonts.plusJakartaSans(color: colorOrange, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tombol Dengan Efek Pengunci & Animasi Loading Dalam Box
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: authLoading
                                ? const Center(child: CircularProgressIndicator(color: colorPrimary, strokeWidth: 3))
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      minimumSize: const Size(double.infinity, 52),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: Text('Masuk ke Akun', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: colorSlate200, thickness: 1.2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('atau lanjut dengan', style: GoogleFonts.plusJakartaSans(color: colorSlate500, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Expanded(child: Divider(color: colorSlate200, thickness: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tombol Google Modern
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: authLoading ? null : _handleGoogleLogin, 
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: colorSlate200, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌐 ', style: TextStyle(fontSize: 16)), 
                          const SizedBox(width: 8),
                          Text('Google Account', style: GoogleFonts.plusJakartaSans(color: colorSlate900, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun? ', style: GoogleFonts.plusJakartaSans(color: colorSlate500, fontSize: 14, fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const RegisterScreen(),
                              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Text('Daftar di sini', style: GoogleFonts.plusJakartaSans(color: colorPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _tailwindInput(String emoji, String hint) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10),
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: colorSlate500, fontSize: 14, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), 
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorSlate200, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorSlate200, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorPrimary, width: 1.8)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
    );
  }

  InputDecoration _inputPasswordDecoration(String emoji, String hint, {required Widget suffix}) {
    return _tailwindInput(emoji, hint).copyWith(suffixIcon: suffix);
  }
}