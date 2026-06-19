import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  // ── Ganti sesuai environment secara dinamis ──
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:8001/api/v1';
    }
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8001/api/v1'; // Android Emulator
    }
    
    // Default untuk Windows Desktop, iOS Simulator, dll.
    return 'http://127.0.0.1:8001/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login        = '/auth/login';
  static const String register     = '/auth/register';
  static const String logout       = '/auth/logout';
  static const String me           = '/auth/me';
  static const String updateProfile= '/auth/profile';

  static const String wisata        = '/wisata';
  static const String kategori      = '/kategori-wisata';
  static const String reservasi     = '/user/reservasi';
  static const String bookingCamping= '/user/booking-camping';
  static const String bookingPenginapan='/user/booking-penginapan';
  static const String sewaPeralatan = '/user/sewa-peralatan';
  static const String ulasan        = '/user/ulasan';
  static const String notifikasi    = '/user/notifikasi';
}
