class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8001/api/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Endpoints
  static const String login         = '/auth/login';
  static const String register      = '/auth/register';
  static const String wisata        = '/wisata';
  static const String reservasi     = '/reservasi';
  static const String camping       = '/camping';
  static const String penginapan    = '/penginapan';
  static const String peralatan     = '/peralatan';
  static const String pembayaran    = '/pembayaran';
  static const String profil        = '/profil';
  static const String notifikasi    = '/notifikasi';
  static const String riwayat       = '/riwayat';
}