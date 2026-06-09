import 'dart:async';

class BookingRepository {
  // Singleton Pattern: Memastikan satu repositori terbagi rata di semua screen
  static final BookingRepository _instance = BookingRepository._internal();
  factory BookingRepository() => _instance;
  BookingRepository._internal();

  // Database memori lokal untuk simulasi daftar riwayat realtime
  final List<Map<String, dynamic>> _riwayatList = [];

  List<Map<String, dynamic>> get getRiwayat => _riwayatList;

  // 1. Booking Tiket Masuk
  Future<Map<String, dynamic>> createBookingTiket(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final id = 'TKT-${DateTime.now().millisecondsSinceEpoch}';

      // Mengonversi data total_harga ke int dengan aman untuk mencegah TypeError di Flutter Web
      final int hargaTotal = int.tryParse(data['total_harga'].toString()) ?? 25000;

      final Map<String, dynamic> newBooking = {
        'id': id,
        'tipe': 'Tiket Masuk',
        'layanan': 'Tiket Masuk Wisata Citiis',
        'tanggal': data['tanggal_kunjungan'] ?? '-',
        'detail': '${data['jumlah_tiket'] ?? 1} Orang',
        'total_harga': hargaTotal,
        'status': 'Belum Dibayar',
      };
      
      _riwayatList.insert(0, newBooking);

      // Mengembalikan Map dengan kepastian tipe data agar Flutter Web tidak membaca undefined
      return {
        'success': true,
        'booking_id': id,
        'payment_url': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$id',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat reservasi tiket lokal: $e',
      };
    }
  }

  // 2. Booking Camping
  Future<Map<String, dynamic>> createBookingCamping(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final id = 'BCP-${DateTime.now().millisecondsSinceEpoch}';
      
      final int hargaTotal = int.tryParse(data['total_harga'].toString()) ?? 75000;

      final Map<String, dynamic> newBooking = {
        'id': id,
        'tipe': 'Sewa Camp',
        'layanan': data['nama_paket'] ?? 'Paket Camping',
        'tanggal': '${data['tanggal_checkin'] ?? "-"} s/d ${data['tanggal_checkout'] ?? "-"}',
        'detail': '${data['jumlah_tamu'] ?? 1} Peserta',
        'total_harga': hargaTotal,
        'status': 'Belum Dibayar',
      };

      _riwayatList.insert(0, newBooking);

      return {
        'success': true,
        'booking_id': id,
        'payment_url': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$id',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat reservasi camping: $e',
      };
    }
  }

  // 3. Booking Penginapan Hotel
  Future<Map<String, dynamic>> createBookingPenginapan(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final id = 'BGP-${DateTime.now().millisecondsSinceEpoch}';
      
      final int hargaTotal = int.tryParse(data['total_harga'].toString()) ?? 350000;
      
      final Map<String, dynamic> newBooking = {
        'id': id,
        'tipe': 'Penginapan',
        'layanan': data['tipe_kamar'] ?? 'Kamar Resort Wisata',
        'tanggal': '${data['tanggal_checkin'] ?? "-"} s/d ${data['tanggal_checkout'] ?? "-"}',
        'detail': 'Akomodasi Kamar',
        'total_harga': hargaTotal,
        'status': 'Belum Dibayar',
      };

      _riwayatList.insert(0, newBooking);

      return {
        'success': true,
        'booking_id': id,
        'payment_url': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$id',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat reservasi penginapan: $e',
      };
    }
  }

  // 4. Booking Sewa Alat Camp
  Future<Map<String, dynamic>> createBookingAlat(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final id = 'ALT-${DateTime.now().millisecondsSinceEpoch}';

      final int hargaTotal = int.tryParse(data['total_harga'].toString()) ?? 0;

      final Map<String, dynamic> newBooking = {
        'id': id,
        'tipe': 'Sewa Alat',
        'layanan': data['ringkasan_alat'] ?? 'Sewa Peralatan Camping',
        'tanggal': 'Durasi: ${data['durasi'] ?? 1} Hari',
        'detail': '${data['total_item'] ?? 0} Barang',
        'total_harga': hargaTotal,
        'status': 'Belum Dibayar',
      };

      _riwayatList.insert(0, newBooking);

      return {
        'success': true,
        'booking_id': id,
        'payment_url': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$id',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat sewa alat: $e',
      };
    }
  }

  // Aksi Update Status saat Pembayaran Sukses di-klik
  void updateStatusBayar(String id) {
    final idx = _riwayatList.indexWhere((element) => element['id'] == id);
    if (idx != -1) {
      _riwayatList[idx]['status'] = 'Lunas';
    }
  }

  // Fungsi tambahan cadangan jika diperlukan oleh sistem lama
  Future<Map<String, dynamic>> createReservasi(Map<String, dynamic> data) async {
    return await createBookingTiket(data);
  }
}