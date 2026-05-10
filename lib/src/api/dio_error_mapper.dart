import 'package:dio/dio.dart';
import 'api_exceptions.dart';

/// Convierte una [DioException] en la jerarquía de excepciones del paquete
/// y la lanza inmediatamente. Centralizamos aquí el mapeo para que todos los
/// repositorios apliquen las mismas reglas y no haya divergencias entre
/// ficheros.
///
/// Reglas:
/// - 401 → [UnauthorizedException]
/// - timeout o error de red → [NetworkException]
/// - cualquier otro → [ApiException] con [defaultMsg]
///
/// Devuelve `Never`: el llamador puede usarla como expresión y el analizador
/// entiende que la ejecución no continúa.
///
/// ```dart
/// try {
///   final response = await _client.dio.get('/habitos');
///   return response.data;
/// } on DioException catch (e) {
///   handleDioError(e, 'Error al cargar hábitos');
/// }
/// ```
///
/// Si un repositorio necesita lógica adicional (por ejemplo distinguir un
/// 400 con mensaje específico, como hace [auth_repository] con login), puede
/// inspeccionar el error antes y delegar aquí solo en el caso genérico.
Never handleDioError(DioException e, String defaultMsg) {
  if (e.response?.statusCode == 401) {
    throw UnauthorizedException();
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.receiveTimeout) {
    throw NetworkException('No se pudo conectar al servidor');
  }
  throw ApiException(defaultMsg);
}
