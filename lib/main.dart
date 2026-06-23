import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'presentation/screens/auth/splash_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/wisata_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/booking_provider.dart'; // ✅ TAMBAH INI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<WisataProvider>(
          create: (_) => WisataProvider(),
        ),
        ChangeNotifierProvider<NotifikasiProvider>(
          create: (_) => NotifikasiProvider(),
        ),
        // ✅ TAMBAH: Provider riwayat semua booking dari API
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
      ],
      child: const CitiisGoApp(),
    ),
  );
}

class CitiisGoApp extends StatelessWidget {
  const CitiisGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CitiisGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}