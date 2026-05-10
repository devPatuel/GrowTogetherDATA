import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/dio_error_mapper.dart';
import '../models/notificacion.dart';

/// Repositorio cliente para gestionar los recordatorios de habitos del usuario.
///
/// Wrappea los endpoints `/api/v1/notificaciones`. La entrega real de la notificacion
/// al dispositivo no la hace el backend: este repositorio solo gestiona la persistencia
/// en la API, y la app se encarga despues de programarlas en local con
/// flutter_local_notifications.
class NotificacionRepository {
  final DioClient _client;

  NotificacionRepository(this._client);

  /// Devuelve todas las notificaciones del usuario autenticado, recorriendo todos
  /// sus habitos. Pensado para sincronizar las locales tras login o reinstalacion.
  Future<List<Notificacion>> listarDelUsuarioAutenticado() async {
    try {
      final response = await _client.dio.get('/notificaciones/usuario');
      final list = response.data as List;
      return list.map((json) => Notificacion.fromJson(json)).toList();
    } on DioException catch (e) {
      handleDioError(e, 'Error al cargar notificaciones del usuario');
    }
  }

  /// Devuelve las notificaciones de un habito concreto.
  Future<List<Notificacion>> listarPorHabito(int habitoId) async {
    try {
      final response = await _client.dio.get('/notificaciones/habito/$habitoId');
      final list = response.data as List;
      return list.map((json) => Notificacion.fromJson(json)).toList();
    } on DioException catch (e) {
      handleDioError(e, 'Error al cargar notificaciones del habito');
    }
  }

  /// Crea una notificacion para el habito indicado.
  ///
  /// La frecuencia real (diaria o por días específicos) se infiere del
  /// hábito asociado en el servicio de notificaciones locales del cliente.
  Future<Notificacion> crear({
    required int habitoId,
    required String mensaje,
    required int hora,
    required int minuto,
    bool activa = true,
  }) async {
    try {
      final response = await _client.dio.post('/notificaciones', data: {
        'habitoId': habitoId,
        'mensaje': mensaje,
        'horaProgramada': _formatHora(hora, minuto),
        'activa': activa,
      });
      return Notificacion.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e, 'Error al crear notificacion');
    }
  }

  /// Actualiza una notificacion existente. Todos los campos del DTO son
  /// obligatorios en la API, así que se reenvía el conjunto completo.
  Future<Notificacion> actualizar(int id, {
    required int habitoId,
    required String mensaje,
    required int hora,
    required int minuto,
    required bool activa,
  }) async {
    try {
      final response = await _client.dio.put('/notificaciones/$id', data: {
        'habitoId': habitoId,
        'mensaje': mensaje,
        'horaProgramada': _formatHora(hora, minuto),
        'activa': activa,
      });
      return Notificacion.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e, 'Error al actualizar notificacion');
    }
  }

  /// Elimina una notificacion por ID.
  Future<void> eliminar(int id) async {
    try {
      await _client.dio.delete('/notificaciones/$id');
    } on DioException catch (e) {
      handleDioError(e, 'Error al eliminar notificacion');
    }
  }

  static String _formatHora(int hora, int minuto) =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}:00';
}
