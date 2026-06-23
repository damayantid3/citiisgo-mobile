class ApiConfig {
  // ───────────────────────────────────────────────────────────────────────────
  // PANDUAN BASE URL:
  // 1. Jika Anda mengakses web/mobile murni di 1 LAPTOP/KOMPUTER YANG SAMA, 
  //    gunakan: 'http://127.0.0.1:8000/api/v1' ATAU 'http://localhost:8000/api/v1'
  //
  // 2. Jika Anda mengakses lewat HP (lewat Wi-Fi/Hotspot yang sama), ubah 
  //    angka '192.168.1.3' menjadi IP Address IPv4 laptop Anda saat ini.
  // ───────────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:8000/api/v1';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Endpoints
  static const String login      = '/auth/login';
  static const String register   = '/auth/register';
  static const String wisata     = '/wisata';
  static const String reservasi  = '/reservasi';
  static const String camping    = '/camping';
  static const String penginapan = '/penginapan';
  static const String peralatan  = '/peralatan';
  static const String pembayaran = '/pembayaran';
  static const String profil     = '/profil';
  static const String notifikasi = '/notifikasi';
  static const String riwayat   = '/riwayat';
}