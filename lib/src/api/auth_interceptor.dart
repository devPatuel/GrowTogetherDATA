import 'package:dio/dio.dart';
import '../local/secure_storage_service.dart';

/// Interceptor de Dio que centraliza la autenticación HTTP del paquete.
///
/// - En cada request inyecta `Authorization: Bearer <token>` si hay token
///   guardado en [SecureStorageService] y fija el `Content-Type` a JSON.
/// - Ante un 401 de la API limpia las credenciales locales: el token o ha
///   expirado o ha sido revocado (cambio de contraseña, bloqueo). La UI se
///   entera al detectar que no hay sesión y redirige a login.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.deleteAll();
    }
    handler.next(err);
  }
}
