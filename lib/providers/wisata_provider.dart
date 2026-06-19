import 'package:flutter/material.dart';
import '../data/models/wisata_model.dart';
import '../data/repositories/wisata_repository.dart';

class WisataProvider extends ChangeNotifier {
  final WisataRepository _repository = WisataRepository();
  List<WisataModel> _allWisata = [];
  String _kategoriAktif = 'Semua';
  bool _isLoading = false;

  List<WisataModel> get allWisata => _allWisata;
  List<WisataModel> get popularWisata => _allWisata.where((w) => w.tag == 'Populer' || w.tag == 'Trending' || w.rating >= 4.5).toList();
  List<WisataModel> get nearbyWisata => _allWisata.where((w) => (w.jarakKm != null && w.jarakKm! > 0)).toList();
  String get kategoriAktif => _kategoriAktif;
  bool get isLoading => _isLoading;

  List<WisataModel> get filteredWisata {
    if (_kategoriAktif == 'Semua') return _allWisata;
    return _allWisata.where((w) => w.kategori?.nama == _kategoriAktif || _kategoriAktif.toLowerCase().contains(w.kategori?.nama.toLowerCase() ?? '')).toList();
  }

  Future<void> loadWisata() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getWisata();
    if (result['success'] == true) {
      _allWisata = result['data'] as List<WisataModel>;
    } else {
      _allWisata = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setKategori(String kategori) {
    _kategoriAktif = kategori;
    notifyListeners();
  }
}