import 'package:flutter/material.dart';
import '../core/network/api_service.dart';

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

  factory NotifikasiModel.fromJson(Map<String, dynamic> j) {
    final createdAt = j['created_at'] ?? '';
    return NotifikasiModel(
      id: (j['id'] ?? '').toString(),
      judul: j['judul'] ?? '',
      pesan: j['pesan'] ?? '',
      waktu: _formatRelativeTime(createdAt),
      tipe: j['tipe'] ?? 'promo',
      isRead: j['is_read'] == 1 || j['is_read'] == true,
    );
  }

  static String _formatRelativeTime(String createdAtStr) {
    try {
      final dt = DateTime.parse(createdAtStr).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Baru saja';
    }
  }
}

class NotifikasiProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<NotifikasiModel> _listNotifikasi = [];
  bool _isLoading = false;

  List<NotifikasiModel> get listNotifikasi => _listNotifikasi;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifikasi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getNotifikasi();
      if (res.data['success'] == true || res.data['data'] != null) {
        final List data = res.data['data'] ?? [];
        _listNotifikasi = data.map((n) => NotifikasiModel.fromJson(n)).toList();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> tandaiSemuaDibaca() async {
    for (var notif in _listNotifikasi) {
      notif.isRead = true;
    }
    notifyListeners();

    try {
      await _api.markAllRead();
    } catch (_) {}
  }

  Future<void> tandaiSatuDibaca(String id) async {
    final index = _listNotifikasi.indexWhere((element) => element.id == id);
    if (index != -1) {
      _listNotifikasi[index].isRead = true;
      notifyListeners();

      final numericId = int.tryParse(id);
      if (numericId != null) {
        try {
          await _api.markRead(numericId);
        } catch (_) {}
      }
    }
  }
}