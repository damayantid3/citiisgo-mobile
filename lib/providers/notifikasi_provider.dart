import 'package:flutter/material.dart';

class NotifikasiModel {
  final String id;
  final String judul;
  final String pesan;
  final String waktu;
  final String tipe; // 'sukses', 'batal', 'promo', 'paket'
  bool isRead;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.tipe,
    this.isRead = false,
  });
}

class NotifikasiProvider with ChangeNotifier {
  final List<NotifikasiModel> _listNotifikasi = [
    // Data awal sebagai contoh/promo bawaan
    NotifikasiModel(
      id: 'init-1',
      judul: 'Selamat Datang di CitiisGo! 👋',
      pesan: 'Jelajahi keindahan Gunung Citiis dan nikmati kemudahan booking tiket, camp, serta penginapan dalam satu aplikasi.',
      waktu: 'Baru saja',
      tipe: 'promo',
    ),
  ];

  List<NotifikasiModel> get listNotifikasi => _listNotifikasi;

  // Fungsi Utama: Dipanggil dari screen lain untuk menambah notifikasi secara real-time
  void tambahNotifikasi({
    required String judul,
    required String pesan,
    required String tipe,
  }) {
    final id = 'NTF-${DateTime.now().millisecondsSinceEpoch}';
    _listNotifikasi.insert(
      0,
      NotifikasiModel(id: id, judul: judul, pesan: pesan, waktu: 'Baru saja', tipe: tipe),
    );
    notifyListeners();
  }

  void tandaiSemuaDibaca() {
    for (var notif in _listNotifikasi) {
      notif.isRead = true;
    }
    notifyListeners();
  }

  void tandaiSatuDibaca(String id) {
    final index = _listNotifikasi.indexWhere((element) => element.id == id);
    if (index != -1) {
      _listNotifikasi[index].isRead = true;
      notifyListeners();
    }
  }
}