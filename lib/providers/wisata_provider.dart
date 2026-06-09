import 'package:flutter/material.dart';
import '../data/models/wisata_model.dart';

class WisataProvider extends ChangeNotifier {
  List<WisataModel> _allWisata = [];
  String _kategoriAktif = 'Semua';
  bool _isLoading = false;

  List<WisataModel> get allWisata => _allWisata;
  List<WisataModel> get popularWisata => _allWisata.where((w) => w.tag == 'Populer' || w.tag == 'Trending').toList();
  List<WisataModel> get nearbyWisata => _allWisata.where((w) => w.jarakKm != null && w.jarakKm! > 0).toList();
  String get kategoriAktif => _kategoriAktif;
  bool get isLoading => _isLoading;

  List<WisataModel> get filteredWisata {
    if (_kategoriAktif == 'Semua') return _allWisata;
    // Perbaikan Logika Filter: Membandingkan string nama dari objek kategori model
    return _allWisata.where((w) => w.kategori?.nama == _kategoriAktif).toList();
  }

  Future<void> loadWisata() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _allWisata = []; // Di sini nantinya repositori nyata kamu memuat data dari citiisgo-api
    _isLoading = false;
    notifyListeners();
  }

  void setKategori(String kategori) {
    _kategoriAktif = kategori;
    notifyListeners();
  }
}