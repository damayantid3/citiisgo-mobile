import '../../core/network/api_service.dart';

/// CitiisGo — BookingRepositoryApi
/// Menghubungkan semua transaksi booking wisatawan ke citiisgo-API (port 8001)
/// Gantikan BookingRepository (lokal/memori) dengan class ini.
class BookingRepositoryApi {
  static final BookingRepositoryApi _instance =
      BookingRepositoryApi._internal();
  factory BookingRepositoryApi() => _instance;
  BookingRepositoryApi._internal();

  final ApiService _api = ApiService();

  // ── 1. Tiket Masuk ─────────────────────────────────────────────────────
  /// POST /api/v1/user/reservasi
  Future<Map<String, dynamic>> createBookingTiket(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createReservasi(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'booking_id': body['data']['id']?.toString() ?? '',
          'payment_url': body['data']['payment_url'] ?? '',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat reservasi tiket'
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // Alias untuk kompatibilitas dengan kode lama
  Future<Map<String, dynamic>> createReservasi(
          Map<String, dynamic> data) async =>
      createBookingTiket(data);

  // ── 2. Booking Camping ──────────────────────────────────────────────────
  /// POST /api/v1/user/booking-camping
  Future<Map<String, dynamic>> createBookingCamping(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createBookingCamping(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'booking_id': body['data']['id']?.toString() ?? '',
          'payment_url': body['data']['payment_url'] ?? '',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat booking camping'
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── 3. Booking Penginapan ───────────────────────────────────────────────
  /// POST /api/v1/user/booking-penginapan
  Future<Map<String, dynamic>> createBookingPenginapan(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createBookingPenginapan(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'booking_id': body['data']['id']?.toString() ?? '',
          'payment_url': body['data']['payment_url'] ?? '',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat booking penginapan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── 4. Sewa Peralatan ───────────────────────────────────────────────────
  /// POST /api/v1/user/sewa-peralatan
  Future<Map<String, dynamic>> createBookingAlat(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createSewaPeralatan(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'booking_id': body['data']['id']?.toString() ?? '',
          'payment_url': body['data']['payment_url'] ?? '',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat sewa peralatan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── 5. Ambil Semua Riwayat Booking ─────────────────────────────────────
  /// Menggabungkan tiket + camping + penginapan + alat dari 4 endpoint API
  Future<List<Map<String, dynamic>>> getRiwayatLengkap() async {
    final List<Map<String, dynamic>> riwayat = [];

    // Tiket masuk
    try {
      final resT = await _api.getMyReservasi();
      if (resT.data['success'] == true) {
        final List list =
            resT.data['data']?['data'] ?? resT.data['data'] ?? [];
        for (final item in list) {
          riwayat.add({
            'id': item['id'].toString(),
            'tipe': 'Tiket Masuk',
            'layanan': 'Tiket Masuk Wisata Citiis',
            'tanggal': item['tanggal_kunjungan'] ?? '-',
            'detail': '${item['jumlah_tiket'] ?? 1} Orang',
            'total_harga': item['total_harga'] ?? 0,
            'status': _normalizeStatus(item['status']),
          });
        }
      }
    } catch (_) {}

    // Camping
    try {
      final resC = await _api.getMyBookingCamping();
      if (resC.data['success'] == true) {
        final List list =
            resC.data['data']?['data'] ?? resC.data['data'] ?? [];
        for (final item in list) {
          riwayat.add({
            'id': item['id'].toString(),
            'tipe': 'Sewa Camp',
            'layanan':
                item['paket_camping']?['nama_paket'] ?? 'Paket Camping',
            'tanggal':
                '${item['tanggal_checkin'] ?? "-"} s/d ${item['tanggal_checkout'] ?? "-"}',
            'detail': '${item['jumlah_tamu'] ?? 1} Peserta',
            'total_harga': item['total_harga'] ?? 0,
            'status': _normalizeStatus(item['status']),
          });
        }
      }
    } catch (_) {}

    // Penginapan
    try {
      final resP = await _api.getMyBookingPenginapan();
      if (resP.data['success'] == true) {
        final List list =
            resP.data['data']?['data'] ?? resP.data['data'] ?? [];
        for (final item in list) {
          riwayat.add({
            'id': item['id'].toString(),
            'tipe': 'Penginapan',
            'layanan':
                item['kamar']?['tipe_kamar'] ?? 'Kamar Resort Wisata',
            'tanggal':
                '${item['tanggal_checkin'] ?? "-"} s/d ${item['tanggal_checkout'] ?? "-"}',
            'detail': 'Akomodasi Kamar',
            'total_harga': item['total_harga'] ?? 0,
            'status': _normalizeStatus(item['status']),
          });
        }
      }
    } catch (_) {}

    // Sewa alat
    try {
      final resA = await _api.getMySewaPeralatan();
      if (resA.data['success'] == true) {
        final List list =
            resA.data['data']?['data'] ?? resA.data['data'] ?? [];
        for (final item in list) {
          riwayat.add({
            'id': item['id'].toString(),
            'tipe': 'Sewa Alat',
            'layanan': 'Sewa Peralatan Camping',
            'tanggal': 'Durasi: ${item['durasi_hari'] ?? 1} Hari',
            'detail': '${(item['items'] as List?)?.length ?? 0} Barang',
            'total_harga': item['total_harga'] ?? 0,
            'status': _normalizeStatus(item['status']),
          });
        }
      }
    } catch (_) {}

    // Terbaru di atas
    riwayat.sort((a, b) => b['id'].compareTo(a['id']));
    return riwayat;
  }

  // ── 6. Batalkan Booking ─────────────────────────────────────────────────
  Future<bool> cancelBooking(String tipe, int id) async {
    try {
      switch (tipe) {
        case 'Tiket Masuk':
          final r = await _api.cancelReservasi(id);
          return r.data['success'] == true;
        case 'Sewa Camp':
          final r = await _api.cancelBookingCamping(id);
          return r.data['success'] == true;
        case 'Penginapan':
          final r = await _api.cancelBookingPenginapan(id);
          return r.data['success'] == true;
        case 'Sewa Alat':
          final r = await _api.cancelSewaPeralatan(id);
          return r.data['success'] == true;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────
  /// Normalisasi status dari API ke label tampilan
  String _normalizeStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'pending':
        return 'Belum Dibayar';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'completed':
      case 'paid':
        return 'Lunas';
      case 'cancelled':
      case 'canceled':
        return 'Dibatalkan';
      default:
        return status?.toString() ?? 'Belum Dibayar';
    }
  }
}