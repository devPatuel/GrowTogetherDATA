import 'package:dio/dio.dart';
import '../local/secure_storage_service.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient(ApiConfig config, SecureStorageService storage) {
    dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
    ));
    dio.interceptors.add(AuthInterceptor(storage));
  }
}
