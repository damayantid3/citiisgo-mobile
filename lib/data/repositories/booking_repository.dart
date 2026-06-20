import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_service.dart';

class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();
  factory BookingRepository() => _instance;
  BookingRepository._internal();

  final ApiService _api = ApiService();
  final List<Map<String, dynamic>> _riwayatList = [];
  List<Map<String, dynamic>> get getRiwayat => _riwayatList;

  // ─── 1. Booking Tiket Masuk ───────────────────────────────────────────
  Future<Map<String, dynamic>> createBookingTiket(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createReservasi({
        'wisata_id': data['wisata_id'],
        'tanggal_kunjungan': data['tanggal_kunjungan'],
        'jumlah_tiket': data['jumlah_tiket'],
      });
      final body = res.data;
      if (body['success'] == true) {
        final reservasi = body['data'];
        final kodeBooking = reservasi['kode_booking'] as String;
        final totalHarga = _safeInt(reservasi['total_harga']);
        _riwayatList.insert(0, {
          'id': kodeBooking,
          'tipe': 'Tiket Masuk',
          'layanan':
              reservasi['wisata']?['nama'] ?? 'Tiket Masuk Wisata Citiis',
          'tanggal': reservasi['tanggal_kunjungan'] ??
              data['tanggal_kunjungan'] ??
              '-',
          'detail': '${data['jumlah_tiket'] ?? 1} Orang',
          'total_harga': totalHarga,
          'status': 'Belum Dibayar',
        });
        return {
          'success': true,
          'booking_id': kodeBooking,
          'total_harga': totalHarga,
          'payment_url': body['payment_url']
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat reservasi tiket.'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal terhubung ke server.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── 2. Booking Camping ───────────────────────────────────────────────
  Future<Map<String, dynamic>> createBookingCamping(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createBookingCamping({
        'paket_camping_id': data['paket_camping_id'],
        'tanggal_checkin': data['tanggal_checkin'],
        'tanggal_checkout': data['tanggal_checkout'],
        'jumlah_tamu': data['jumlah_tamu'],
      });
      final body = res.data;
      if (body['success'] == true) {
        final booking = body['data'];
        final kodeBooking = booking['kode_booking'] as String;
        final totalHarga = _safeInt(booking['total_harga']);
        _riwayatList.insert(0, {
          'id': kodeBooking,
          'tipe': 'Sewa Camp',
          'layanan': data['nama_paket'] ??
              booking['paket']?['nama_paket'] ??
              'Paket Camping',
          'tanggal':
              '${data['tanggal_checkin'] ?? "-"} s/d ${data['tanggal_checkout'] ?? "-"}',
          'detail': '${data['jumlah_tamu'] ?? 1} Peserta',
          'total_harga': totalHarga,
          'status': 'Belum Dibayar',
        });
        return {
          'success': true,
          'booking_id': kodeBooking,
          'total_harga': totalHarga,
          'payment_url': body['payment_url']
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat booking camping.'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal terhubung ke server.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── 3. Booking Penginapan ────────────────────────────────────────────
  Future<Map<String, dynamic>> createBookingPenginapan(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createBookingPenginapan({
        'kamar_id': data['kamar_id'],
        'tanggal_checkin': data['tanggal_checkin'],
        'tanggal_checkout': data['tanggal_checkout'],
        'jumlah_tamu': data['jumlah_tamu'],
        'jumlah_kamar': data['jumlah_kamar'] ?? 1,
      });
      final body = res.data;
      if (body['success'] == true) {
        final booking = body['data'];
        final kodeBooking = booking['kode_booking'] as String;
        final totalHarga = _safeInt(booking['total_harga']);
        _riwayatList.insert(0, {
          'id': kodeBooking,
          'tipe': 'Penginapan',
          'layanan': data['tipe_kamar'] ??
              booking['kamar']?['tipe_kamar'] ??
              'Kamar Resort Wisata',
          'tanggal':
              '${data['tanggal_checkin'] ?? "-"} s/d ${data['tanggal_checkout'] ?? "-"}',
          'detail': 'Akomodasi Kamar',
          'total_harga': totalHarga,
          'status': 'Belum Dibayar',
        });
        return {
          'success': true,
          'booking_id': kodeBooking,
          'total_harga': totalHarga,
          'payment_url': body['payment_url']
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat booking penginapan.'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal terhubung ke server.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── 4. Sewa Peralatan ────────────────────────────────────────────────
  Future<Map<String, dynamic>> createBookingAlat(
      Map<String, dynamic> data) async {
    try {
      final res = await _api.createSewaPeralatan({
        'wisata_id': data['wisata_id'],
        'tanggal_mulai': data['tanggal_mulai'],
        'tanggal_selesai': data['tanggal_selesai'],
        'items': data['items'],
      });
      final body = res.data;
      if (body['success'] == true) {
        final sewa = body['data'];
        final kodeSewa = sewa['kode_sewa'] as String;
        final totalHarga = _safeInt(sewa['total_harga']);
        _riwayatList.insert(0, {
          'id': kodeSewa,
          'tipe': 'Sewa Alat',
          'layanan': data['ringkasan_alat'] ?? 'Sewa Peralatan Camping',
          'tanggal': 'Durasi: ${data['durasi'] ?? 1} Hari',
          'detail': '${data['total_item'] ?? 0} Barang',
          'total_harga': totalHarga,
          'status': 'Belum Dibayar',
        });
        return {
          'success': true,
          'booking_id': kodeSewa,
          'total_harga': totalHarga,
          'payment_url': body['payment_url']
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat sewa peralatan.'
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal terhubung ke server.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── Helper alias ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createReservasi(
          Map<String, dynamic> data) async =>
      createBookingTiket(data);

  void updateStatusBayar(String id) {
    final idx = _riwayatList.indexWhere((e) => e['id'] == id);
    if (idx != -1) _riwayatList[idx]['status'] = 'Lunas';
  }

  // ─── 5. Riwayat dari API ──────────────────────────────────────────────
  String _statusLabel(Map<String, dynamic>? pembayaran, String fallbackStatus) {
    if (fallbackStatus == 'completed' || fallbackStatus == 'returned') return 'Selesai';
    if (fallbackStatus == 'cancelled') return 'Dibatalkan';
    if (fallbackStatus == 'confirmed') return 'Lunas';
    final s = pembayaran?['status'];
    if (s == 'paid' || s == 'settlement' || s == 'success') return 'Lunas';
    if (s == 'failed' || s == 'expire' || s == 'cancelled' || s == 'deny') return 'Dibatalkan';
    return 'Belum Dibayar';
  }

  Future<List<Map<String, dynamic>>> getRiwayatFromApi() async {
    final List<Map<String, dynamic>> hasil = [];

    Future<void> safeFetch(Future<void> Function() fn) async {
      try {
        await fn();
      } catch (_) {}
    }

    await safeFetch(() async {
      final res = await _api.getMyReservasi();
      final dataObj = res.data['data'];
      final list = dataObj is List ? dataObj : (dataObj['data'] as List? ?? []);
      for (final r in list) {
        hasil.add({
          'id': r['kode_booking'],
          'numeric_id': r['id'],
          'tipe_raw': 'reservasi',
          'tipe': 'Tiket Masuk',
          'layanan': r['wisata']?['nama'] ?? 'Tiket Masuk Wisata',
          'tanggal': r['tanggal_kunjungan'] ?? '-',
          'detail': '${r['jumlah_tiket'] ?? 1} Orang',
          'total_harga': _safeInt(r['total_harga']),
          'status': _statusLabel(r['pembayaran'], r['status']),
          'payment_url': _safePaymentUrl(r['pembayaran']),
          'created_at': r['created_at'],
        });
      }
    });

    await safeFetch(() async {
      final res = await _api.getMyBookingCamping();
      final dataObj = res.data['data'];
      final list = dataObj is List ? dataObj : (dataObj['data'] as List? ?? []);
      for (final r in list) {
        hasil.add({
          'id': r['kode_booking'],
          'numeric_id': r['id'],
          'tipe_raw': 'booking_camping',
          'tipe': 'Sewa Camp',
          'layanan': r['paket']?['nama_paket'] ?? 'Paket Camping',
          'tanggal':
              '${r['tanggal_checkin'] ?? "-"} s/d ${r['tanggal_checkout'] ?? "-"}',
          'detail': '${r['jumlah_tamu'] ?? 1} Peserta',
          'total_harga': _safeInt(r['total_harga']),
          'status': _statusLabel(r['pembayaran'], r['status']),
          'payment_url': _safePaymentUrl(r['pembayaran']),
          'created_at': r['created_at'],
        });
      }
    });

    await safeFetch(() async {
      final res = await _api.getMyBookingPenginapan();
      final dataObj = res.data['data'];
      final list = dataObj is List ? dataObj : (dataObj['data'] as List? ?? []);
      for (final r in list) {
        hasil.add({
          'id': r['kode_booking'],
          'numeric_id': r['id'],
          'tipe_raw': 'booking_penginapan',
          'tipe': 'Penginapan',
          'layanan': r['kamar']?['tipe_kamar'] ?? 'Kamar Penginapan',
          'tanggal':
              '${r['tanggal_checkin'] ?? "-"} s/d ${r['tanggal_checkout'] ?? "-"}',
          'detail': 'Akomodasi Kamar',
          'total_harga': _safeInt(r['total_harga']),
          'status': _statusLabel(r['pembayaran'], r['status']),
          'payment_url': _safePaymentUrl(r['pembayaran']),
          'created_at': r['created_at'],
        });
      }
    });

    await safeFetch(() async {
      final res = await _api.getMySewaPeralatan();
      final dataObj = res.data['data'];
      final list = dataObj is List ? dataObj : (dataObj['data'] as List? ?? []);
      for (final r in list) {
        hasil.add({
          'id': r['kode_sewa'],
          'numeric_id': r['id'],
          'tipe_raw': 'sewa_peralatan',
          'tipe': 'Sewa Alat',
          'layanan': 'Sewa Peralatan Camping',
          'tanggal':
              '${r['tanggal_mulai'] ?? "-"} s/d ${r['tanggal_selesai'] ?? "-"}',
          'detail': '${(r['detail'] as List?)?.length ?? 0} Jenis Barang',
          'total_harga': _safeInt(r['total_harga']),
          'status': _statusLabel(r['pembayaran'], r['status']),
          'payment_url': _safePaymentUrl(r['pembayaran']),
          'created_at': r['created_at'],
        });
      }
    });

    hasil.sort((a, b) {
      final ca = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime(1970);
      final cb = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
          DateTime(1970);
      final cmp = cb.compareTo(ca);
      if (cmp != 0) return cmp;

      final aId = a['numeric_id'] as int? ?? 0;
      final bId = b['numeric_id'] as int? ?? 0;
      return bId.compareTo(aId);
    });

    return hasil;
  }

  // ─── 6. Cancel Booking ────────────────────────────────────────────────
  Future<Map<String, dynamic>> cancelBooking(
      String tipeRaw, int numericId) async {
    try {
      switch (tipeRaw) {
        case 'reservasi':
          await _api.cancelReservasi(numericId);
          break;
        case 'booking_camping':
          await _api.cancelBookingCamping(numericId);
          break;
        case 'booking_penginapan':
          await _api.cancelBookingPenginapan(numericId);
          break;
        case 'sewa_peralatan':
          await _api.cancelSewaPeralatan(numericId);
          break;
        default:
          return {'success': false, 'message': 'Jenis booking tidak dikenali.'};
      }
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal membatalkan booking.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── 6b. Complete Booking (Manual) ────────────────────────────────────
  Future<Map<String, dynamic>> completeBooking(
      String tipeRaw, int numericId) async {
    try {
      switch (tipeRaw) {
        case 'reservasi':
          await _api.completeReservasi(numericId);
          break;
        case 'booking_camping':
          await _api.completeBookingCamping(numericId);
          break;
        case 'booking_penginapan':
          await _api.completeBookingPenginapan(numericId);
          break;
        case 'sewa_peralatan':
          await _api.completeSewaPeralatan(numericId);
          break;
        default:
          return {'success': false, 'message': 'Jenis booking tidak dikenali.'};
      }
      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Gagal memproses penyelesaian.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ─── 7. Cek Status Pembayaran ─────────────────────────────────────────
  Future<Map<String, dynamic>> cekStatusPembayaran(String kodeBooking) async {
    try {
      final riwayat = await getRiwayatFromApi();
      debugPrint('[DEBUG CekStatus] Checking status for: $kodeBooking');
      for (var r in riwayat) {
        debugPrint('[DEBUG CekStatus] Booking in list: id=${r['id']}, tipe_raw=${r['tipe_raw']}, status=${r['status']}');
      }
      final item = riwayat.firstWhere(
        (r) => r['id'] == kodeBooking,
        orElse: () => {},
      );
      if (item.isEmpty) {
        debugPrint('[DEBUG CekStatus] Booking NOT found for: $kodeBooking');
        return {'success': false, 'message': 'Data booking tidak ditemukan.'};
      }
      return {'success': true, 'status': item['status']};
    } catch (e) {
      debugPrint('[DEBUG CekStatus] Error checking status: $e');
      return {'success': false, 'message': 'Gagal memeriksa status: $e'};
    }
  }

  String _safePaymentUrl(Map<dynamic, dynamic>? pembayaran) {
    if (pembayaran == null) return '';
    final url = pembayaran['payment_url']?.toString() ?? '';
    if (url.isNotEmpty) return url;

    final kode = pembayaran['kode_transaksi']?.toString() ?? '';
    if (kode.isNotEmpty) {
      return 'http://127.0.0.1:8001/api/v1/pembayaran/simulasi?kode_transaksi=$kode';
    }
    return '';
  }

  int _safeInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.round();
    if (val is num) return val.toInt();
    return (double.tryParse(val.toString()) ?? 0.0).round();
  }
}
