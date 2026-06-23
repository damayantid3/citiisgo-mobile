import 'package:flutter/material.dart';
import '../data/repositories/booking_repository_api.dart';

/// Provider untuk mengelola riwayat semua booking wisatawan
/// Daftarkan di main.dart → MultiProvider
class BookingProvider extends ChangeNotifier {
  final BookingRepositoryApi _repo = BookingRepositoryApi();

  List<Map<String, dynamic>> _riwayat = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get riwayat => _riwayat;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Hitung jumlah booking per tipe
  int countByTipe(String tipe) =>
      _riwayat.where((r) => r['tipe'] == tipe).length;

  /// Load semua riwayat dari API (tiket + camping + penginapan + alat)
  Future<void> loadRiwayat() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _riwayat = await _repo.getRiwayatLengkap();
    } catch (e) {
      _error = 'Gagal memuat riwayat: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadRiwayat();

  Future<bool> cancelBooking(String tipe, int id) async {
    final success = await _repo.cancelBooking(tipe, id);
    if (success) await loadRiwayat();
    return success;
  }
}