import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class DioClient {
  static Dio? _dio;
  // Gunakan satu storage global agar konsisten
  static const storage = FlutterSecureStorage();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(dio),
      _LogInterceptor(),
    ]);

    return dio;
  }

  static void reset() => _dio = null;
}

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  _AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await DioClient.storage.read(key: 'api_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await DioClient.storage.delete(key: 'api_token');
      await DioClient.storage.delete(key: 'user');
      // TODO: Pemicu event logout global di AuthProvider/GoRouter di sini
    }
    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      print('[API REQ] ${options.method} ──> ${options.baseUrl}${options.path}');
      if (options.data != null) print('[API BODY] ${options.data}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      print('[API ERR] ${err.response?.statusCode} ──> ${err.requestOptions.path}');
      print('[API ERR MSG] ${err.response?.data ?? err.message}');
      return true;
    }());
    handler.next(err);
  }
}