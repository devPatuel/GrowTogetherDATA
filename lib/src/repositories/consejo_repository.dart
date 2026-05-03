import 'package:dio/dio.dart';
import '../api/api_exceptions.dart';
import '../api/dio_client.dart';
import '../models/consejo.dart';

/// Repositorio cliente para consultar el consejo del día desde la app.
///
/// La gestión completa de consejos vive en [AdminRepository]: este repositorio
/// solo expone lo que el usuario final necesita (un consejo asignado a hoy).
class ConsejoRepository {
  final DioClient _client;

  ConsejoRepository(this._client);

  /// Devuelve el consejo activo asignado a la fecha de hoy o null si no hay.
  /// La API responde 204 No Content cuando no existe consejo para hoy.
  Future<Consejo?> obtenerConsejoDeHoy() async {
    try {
      final response = await _client.dio.get('/usuarios/consejo/hoy');
      if (response.statusCode == 204 || response.data == null) return null;
      return Consejo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException('Error al obtener el consejo de hoy');
    }
  }
}
