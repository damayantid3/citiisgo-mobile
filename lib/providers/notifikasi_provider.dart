import 'package:flutter/material.dart';
import '../../core/network/api_service.dart'; // ✅ untuk load dari API

// ── Model ────────────────────────────────────────────────────────────────
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

  factory NotifikasiModel.fromJson(Map<String, dynamic> j) => NotifikasiModel(
        id     : j['id'].toString(),
        judul  : j['judul'] ?? j['title'] ?? 'Notifikasi',
        pesan  : j['pesan'] ?? j['message'] ?? '',
        waktu  : j['created_at'] ?? 'Baru saja',
        tipe   : j['tipe'] ?? j['type'] ?? 'promo',
        isRead : j['is_read'] == true || j['read_at'] != null,
      );
}

// ── Provider ─────────────────────────────────────────────────────────────
class NotifikasiProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  final List<NotifikasiModel> _listNotifikasi = [
    NotifikasiModel(
      id    : 'init-1',
      judul : 'Selamat Datang di CitiisGo! 👋',
      pesan : 'Jelajahi keindahan Gunung Citiis dan nikmati kemudahan '
          'booking tiket, camp, serta penginapan dalam satu aplikasi.',
      waktu : 'Baru saja',
      tipe  : 'promo',
    ),
  ];

  bool _loadingApi = false;

  List<NotifikasiModel> get listNotifikasi => _listNotifikasi;
  bool get loadingApi => _loadingApi;

  // ── Load dari API /user/notifikasi ──────────────────────────────────────
  Future<void> loadNotifikasiDariApi() async {
    _loadingApi = true;
    notifyListeners();

    try {
      final res = await _api.getNotifikasi();
      if (res.data['success'] == true) {
        final List raw = res.data['data'] ?? [];
        final fromApi = raw
            .map((j) => NotifikasiModel.fromJson(j as Map<String, dynamic>))
            .toList();

        // Merge: notifikasi lokal (init) + dari API, hapus duplikat by id
        final existingIds = _listNotifikasi.map((n) => n.id).toSet();
        for (final n in fromApi) {
          if (!existingIds.contains(n.id)) {
            _listNotifikasi.insert(0, n);
            existingIds.add(n.id);
          }
        }
      }
    } catch (_) {
      // Gagal load dari API → tetap pakai notifikasi lokal
    }

    _loadingApi = false;
    notifyListeners();
  }

  // ── Tambah notifikasi lokal (dipanggil setelah booking / pembayaran) ────
  void tambahNotifikasi({
    required String judul,
    required String pesan,
    required String tipe,
  }) {
    final id = 'NTF-${DateTime.now().millisecondsSinceEpoch}';
    _listNotifikasi.insert(
      0,
      NotifikasiModel(
        id: id, judul: judul, pesan: pesan,
        waktu: 'Baru saja', tipe: tipe,
      ),
    );
    notifyListeners();
  }

  // ── Tandai semua sudah dibaca (lokal + API) ─────────────────────────────
  Future<void> tandaiSemuaDibaca() async {
    for (final n in _listNotifikasi) {
      n.isRead = true;
    }
    notifyListeners();
    // ✅ Sync ke API di background
    try {
      await _api.markAllRead();
    } catch (_) {}
  }

  // ── Tandai satu dibaca (lokal + API) ────────────────────────────────────
  Future<void> tandaiSatuDibaca(String id) async {
    final index = _listNotifikasi.indexWhere((n) => n.id == id);
    if (index != -1) {
      _listNotifikasi[index].isRead = true;
      notifyListeners();
      // ✅ Sync ke API jika bukan notif lokal (id numerik dari API)
      final parsed = int.tryParse(id);
      if (parsed != null) {
        try {
          await _api.markRead(parsed);
        } catch (_) {}
      }
    }
  }

  // ── Jumlah belum dibaca ──────────────────────────────────────────────────
  int get unreadCount =>
      _listNotifikasi.where((n) => !n.isRead).length;
}