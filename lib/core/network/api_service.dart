import 'package:dio/dio.dart';
import '../network/dio_client.dart';

/// CitiisGo API Service — Mobile
/// Semua request ke citiisgo-api melalui class ini.
class ApiService {
  final Dio _dio = DioClient.instance;

  // ── Auth ───────────────────────────────────────────────────
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/auth/register', data: data);

  Future<Response> login(String email, String password) =>
      _dio.post('/auth/login', data: {'email': email, 'password': password});

  Future<Response> logout() => _dio.post('/auth/logout');

  Future<Response> me() => _dio.get('/auth/me');

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/auth/profile', data: data);

  // ── Wisata (Public) ────────────────────────────────────────
  Future<Response> getWisata({
    String? search,
    int? kategoriId,
    String? sort,
    int page = 1,
  }) =>
      _dio.get('/wisata', queryParameters: {
        if (search != null) 'search': search,
        if (kategoriId != null) 'kategori_id': kategoriId,
        if (sort != null) 'sort': sort,
        'page': page,
        'per_page': 10,
      });

  Future<Response> getWisataDetail(int id)     => _dio.get('/wisata/$id');
  Future<Response> getGaleriWisata(int id)     => _dio.get('/wisata/$id/galeri');
  Future<Response> getFasilitasWisata(int id)  => _dio.get('/wisata/$id/fasilitas');
  Future<Response> getUlasanWisata(int id)     => _dio.get('/wisata/$id/ulasan');
  Future<Response> getKategori()               => _dio.get('/kategori-wisata');

  Future<Response> getPaketCampingPublic(int wisataId) =>
      _dio.get('/wisata/$wisataId/paket-camping');

  Future<Response> getPenginapanPublic(int wisataId) =>
      _dio.get('/wisata/$wisataId/penginapan');

  Future<Response> getKamarPenginapan(int penginapanId) =>
      _dio.get('/penginapan/$penginapanId/kamar');

  Future<Response> getPeralatanPublic(int wisataId) =>
      _dio.get('/wisata/$wisataId/peralatan');

  // ── User: Reservasi ────────────────────────────────────────
  Future<Response> getMyReservasi({int page = 1}) =>
      _dio.get('/user/reservasi', queryParameters: {'page': page});

  Future<Response> createReservasi(Map<String, dynamic> data) =>
      _dio.post('/user/reservasi', data: data);

  Future<Response> getReservasiDetail(int id) =>
      _dio.get('/user/reservasi/$id');

  Future<Response> cancelReservasi(int id) =>
      _dio.delete('/user/reservasi/$id');

  // ── User: Booking Camping ──────────────────────────────────
  Future<Response> getMyBookingCamping({int page = 1}) =>
      _dio.get('/user/booking-camping', queryParameters: {'page': page});

  Future<Response> createBookingCamping(Map<String, dynamic> data) =>
      _dio.post('/user/booking-camping', data: data);

  Future<Response> getBookingCampingDetail(int id) =>
      _dio.get('/user/booking-camping/$id');

  Future<Response> cancelBookingCamping(int id) =>
      _dio.delete('/user/booking-camping/$id');

  // ── User: Booking Penginapan ───────────────────────────────
  Future<Response> getMyBookingPenginapan({int page = 1}) =>
      _dio.get('/user/booking-penginapan', queryParameters: {'page': page});

  Future<Response> createBookingPenginapan(Map<String, dynamic> data) =>
      _dio.post('/user/booking-penginapan', data: data);

  Future<Response> cancelBookingPenginapan(int id) =>
      _dio.delete('/user/booking-penginapan/$id');

  // ── User: Sewa Peralatan ───────────────────────────────────
  Future<Response> getMySewaPeralatan({int page = 1}) =>
      _dio.get('/user/sewa-peralatan', queryParameters: {'page': page});

  Future<Response> createSewaPeralatan(Map<String, dynamic> data) =>
      _dio.post('/user/sewa-peralatan', data: data);

  Future<Response> cancelSewaPeralatan(int id) =>
      _dio.delete('/user/sewa-peralatan/$id');

  // ── User: Ulasan ───────────────────────────────────────────
  Future<Response> createUlasan(Map<String, dynamic> data,
      {List<MultipartFile>? foto}) async {
    final Map<String, dynamic> mapData = {...data};
    
    // Pastikan foto tidak null DAN tidak kosong sebelum dimasukkan ke FormData
    if (foto != null && foto.isNotEmpty) {
      mapData['foto[]'] = foto;
    }

    final formData = FormData.fromMap(mapData);
    return _dio.post('/user/ulasan', data: formData);
  }

  // ── User: Notifikasi ───────────────────────────────────────
  Future<Response> getNotifikasi()     => _dio.get('/user/notifikasi');
  Future<Response> markRead(int id)    => _dio.put('/user/notifikasi/$id/read');
  Future<Response> markAllRead()       => _dio.post('/user/notifikasi/read-all');
}