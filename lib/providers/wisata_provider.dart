import 'package:flutter/material.dart';
import '../data/models/wisata_model.dart';
import '../data/models/kategori_model.dart';
import '../data/repositories/wisata_repository.dart';

/// CitiisGo WisataProvider — Versi terhubung ke API nyata
/// Gantikan isi wisata_provider.dart yang lama dengan ini.
class WisataProvider extends ChangeNotifier {
  final WisataRepository _repo = WisataRepository();

  List<WisataModel> _allWisata = [];
  List<KategoriModel> _kategoriList = [];
  String _kategoriAktif = 'Semua';
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;

  List<WisataModel> get allWisata => _allWisata;
  List<KategoriModel> get kategoriList => _kategoriList;
  String get kategoriAktif => _kategoriAktif;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;

  List<WisataModel> get popularWisata =>
      _allWisata.where((w) => w.rating >= 4.5).toList();

  List<WisataModel> get nearbyWisata =>
      _allWisata.where((w) => (w.jarakKm ?? 0) > 0).toList();

  List<WisataModel> get filteredWisata {
    if (_kategoriAktif == 'Semua') return _allWisata;
    return _allWisata
        .where((w) => w.kategori?.nama == _kategoriAktif)
        .toList();
  }

  /// Load wisata dari API — gantikan method lama yang return []
  Future<void> loadWisata({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _allWisata = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.getWisata(
        page: _currentPage,
        search: search,
        kategoriId: _kategoriAktif == 'Semua' ? null : _getKategoriId(),
      );

      if (result['success'] == true) {
        final List<WisataModel> data =
            (result['data'] as List).cast<WisataModel>();
        _allWisata = refresh ? data : [..._allWisata, ...data];
        _currentPage = result['current_page'] ?? 1;
        _lastPage = result['last_page'] ?? 1;
        _error = null;
      } else {
        _error = result['message'] ?? 'Gagal memuat wisata';
      }
    } catch (e) {
      _error = 'Koneksi gagal: pastikan server API berjalan di port 8001';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load lebih banyak (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    _currentPage++;
    await loadWisata();
  }

  /// Load kategori dari endpoint /kategori-wisata
  Future<void> loadKategori() async {
    try {
      _kategoriList = await _repo.getKategori();
      notifyListeners();
    } catch (_) {}
  }

  /// Set filter kategori aktif
  void setKategori(String kategori) {
    if (_kategoriAktif == kategori) return;
    _kategoriAktif = kategori;
    loadWisata(refresh: true);
    notifyListeners();
  }

  int? _getKategoriId() {
    try {
      return _kategoriList
          .firstWhere((k) => k.nama == _kategoriAktif)
          .id;
    } catch (_) {
      return null;
    }
  }
}