// ─── lib/data/repositories/booking_repository.dart ────────────
import '../../core/network/api_service.dart';
import '../models/booking_camping_model.dart';
import '../models/reservasi_model.dart';

class BookingRepository {
  final ApiService _api = ApiService();
 
  // ── Reservasi ──
  Future<List<ReservasiModel>> getMyReservasi() async {
    try {
      final res = await _api.getMyReservasi();
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((r) => ReservasiModel.fromJson(r)).toList();
    } catch (_) { return []; }
  }
 
  Future<Map<String, dynamic>> createReservasi(Map<String, dynamic> data) async {
    try {
      final res = await _api.createReservasi(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'data': ReservasiModel.fromJson(body['data']),
          'payment_url': body['payment_url'],
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal membuat reservasi.'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal.'};
    }
  }
 
  Future<Map<String, dynamic>> cancelReservasi(int id) async {
    try {
      final res = await _api.cancelReservasi(id);
      return {'success': res.data['success'] == true};
    } catch (_) {
      return {'success': false};
    }
  }
  // ── Booking Camping ──
  Future<List<BookingCampingModel>> getMyBookingCamping() async {
    try {
      final res = await _api.getMyBookingCamping();
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((b) => BookingCampingModel.fromJson(b)).toList();
    } catch (_) { return []; }
  }
 
  Future<Map<String, dynamic>> createBookingCamping(Map<String, dynamic> data) async {
    try {
      final res = await _api.createBookingCamping(data);
      final body = res.data;
      if (body['success'] == true) {
        return {
          'success': true,
          'data': BookingCampingModel.fromJson(body['data']),
          'payment_url': body['payment_url'],
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal booking camping.'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal.'};
    }
  }
 
  // ── Sewa Peralatan ──
  Future<Map<String, dynamic>> createSewaPeralatan(Map<String, dynamic> data) async {
    try {
      final res = await _api.createSewaPeralatan(data);
      final body = res.data;
      if (body['success'] == true) {
        return {'success': true, 'payment_url': body['payment_url']};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal menyewa peralatan.'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal.'};
    }
  }
}
