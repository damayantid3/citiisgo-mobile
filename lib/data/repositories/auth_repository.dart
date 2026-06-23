import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/network/dio_client.dart';
import '../../core/network/api_service.dart';
import '../models/user_model.dart';
 
class AuthRepository {
  // PENTING: Pastikan ApiService kamu menerima DioClient.instance di constructor-nya nanti!
  final ApiService _api = ApiService(); 
 
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.login(email, password);
      final data = res.data;
      
      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user = UserModel.fromJson(data['data']['user']);
        
        await DioClient.storage.write(key: 'api_token', value: token);
        await DioClient.storage.write(key: 'user', value: jsonEncode(user.toJson()));
        
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    } on DioException catch (e) {
      // Mengambil pesan error asli dari response body backend
      final errorMessage = e.response?.data?['message'] ?? 'Gagal terhubung ke server.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem.'};
    }
  }
 
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final res = await _api.register(data);
      final body = res.data;
      if (body['success'] == true) {
        final token = body['data']['token'] as String;
        final user = UserModel.fromJson(body['data']['user']);
        
        await DioClient.storage.write(key: 'api_token', value: token);
        await DioClient.storage.write(key: 'user', value: jsonEncode(user.toJson()));
        
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': body['message'] ?? 'Registrasi gagal'};
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Gagal mendaftarkan akun.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan saat registrasi.'};
    }
  }
 
  Future<void> logout() async {
    try { await _api.logout(); } catch (_) {}
    await DioClient.storage.deleteAll();
  }
 
  Future<UserModel?> getLocalUser() async {
    try {
      final userStr = await DioClient.storage.read(key: 'user');
      if (userStr != null) return UserModel.fromJson(jsonDecode(userStr));
    } catch (_) {}
    return null;
  }
 
  Future<bool> isLoggedIn() async {
    final token = await DioClient.storage.read(key: 'api_token');
    return token != null && token.isNotEmpty;
  }
 
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.updateProfile(data);
      final body = res.data;
      if (body['success'] == true) {
        final user = UserModel.fromJson(body['data']);
        await DioClient.storage.write(key: 'user', value: jsonEncode(user.toJson()));
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': body['message']};
    } on DioException catch (e) {
  print("DEBUG INFO DARI BACKEND: ${e.response?.data}"); // ⬅️ Tambahkan baris ini
  final errorMessage = e.response?.data?['message'] ?? 'Gagal mendaftarkan akun.';
  return {'success': false, 'message': errorMessage};
}
  }
}