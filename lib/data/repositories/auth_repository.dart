// ─── lib/data/repositories/auth_repository.dart ───────────────
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../core/network/api_service.dart';
import '../models/user_model.dart';
 
class AuthRepository {
  final ApiService _api = ApiService();
  static const _storage = FlutterSecureStorage();
 
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.login(email, password);
      final data = res.data;
      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user = UserModel.fromJson(data['data']['user']);
        await _storage.write(key: 'api_token', value: token);
        await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal. Periksa jaringan Anda.'};
    }
  }
 
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final res = await _api.register(data);
      final body = res.data;
      if (body['success'] == true) {
        final token = body['data']['token'] as String;
        final user = UserModel.fromJson(body['data']['user']);
        await _storage.write(key: 'api_token', value: token);
        await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': body['message'] ?? 'Registrasi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal.'};
    }
  }
 
  Future<void> logout() async {
    try { await _api.logout(); } catch (_) {}
    await _storage.deleteAll();
  }
 
  Future<UserModel?> getLocalUser() async {
    try {
      final userStr = await _storage.read(key: 'user');
      if (userStr != null) return UserModel.fromJson(jsonDecode(userStr));
    } catch (_) {}
    return null;
  }
 
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'api_token');
    return token != null && token.isNotEmpty;
  }
 
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.updateProfile(data);
      final body = res.data;
      if (body['success'] == true) {
        final user = UserModel.fromJson(body['data']);
        await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': body['message']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal memperbarui profil.'};
    }
  }
}
 