import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate API

    // Dummy login
    if (email == 'demo@citiisgo.id' && password == 'demo123') {
      _user = UserModel(
        id: 1,
        nama: 'Wisatawan',
        email: email,
        token: 'dummy_token',
        role: 'user',
        status: 'active',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email atau password salah';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nama, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _user = UserModel(
      id: 1,
      nama: nama,
      email: email,
      token: 'dummy_token',
      role: 'user',
      status: 'active',
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}