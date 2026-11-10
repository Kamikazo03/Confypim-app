import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/api_config.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late Dio dio;
  PersistCookieJar? _cookieJar;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/cookies';

    _cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(CookieManager(_cookieJar!));

    _initialized = true;
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureInitialized();

    return dio.get(
      endpoint,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureInitialized();

    return dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureInitialized();

    return dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureInitialized();

    return dio.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ApiClient no ha sido inicializado.');
    }
  }
}