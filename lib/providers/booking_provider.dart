import 'package:flutter/material.dart';
import '../data/models/paket_camping_model.dart';

class BookingProvider extends ChangeNotifier {
  // Camping booking state
  PaketCampingModel? _selectedPaket;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _jumlahTamu = 2;
  String _catatan = '';
  bool _isLoading = false;
  bool _bookingSuccess = false;

  PaketCampingModel? get selectedPaket => _selectedPaket;
  DateTime? get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  int get jumlahTamu => _jumlahTamu;
  String get catatan => _catatan;
  bool get isLoading => _isLoading;
  bool get bookingSuccess => _bookingSuccess;

  int get jumlahMalam => (_checkOut != null && _checkIn != null)
      ? _checkOut!.difference(_checkIn!).inDays
      : 0;

  int get totalHarga {
    if (_selectedPaket == null) return 0;
    return (_selectedPaket!.hargaPerMalam * jumlahMalam) + 10000; // biaya layanan
  }

  void setPaket(PaketCampingModel paket) {
    _selectedPaket = paket;
    notifyListeners();
  }

  void setCheckIn(DateTime date) {
    _checkIn = date;
    if (_checkOut != null && _checkOut!.isBefore(date)) _checkOut = null;
    notifyListeners();
  }

  void setCheckOut(DateTime date) {
    _checkOut = date;
    notifyListeners();
  }

  void setJumlahTamu(int tamu) {
    _jumlahTamu = tamu;
    notifyListeners();
  }

  void setCatatan(String val) {
    _catatan = val;
    notifyListeners();
  }

  Future<bool> submitBooking() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _bookingSuccess = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void reset() {
    _selectedPaket = null;
    _checkIn = null;
    _checkOut = null;
    _jumlahTamu = 2;
    _catatan = '';
    _bookingSuccess = false;
    notifyListeners();
  }
}