import 'package:dio/dio.dart';
import '../api/api_exceptions.dart';
import '../api/dio_client.dart';
import '../api/dio_error_mapper.dart';
import '../models/audit_log.dart';
import '../models/consejo.dart';
import '../models/metricas_admin.dart';
import '../models/usuario_admin.dart';

/// Repositorio que centraliza todas las llamadas del panel de administración
/// contra los endpoints /api/v1/admin de la API.
///
/// No gestiona autenticación: el login del admin se hace con [AuthRepository]
/// reutilizando POST /auth/login. Aquí solo se accede a recursos protegidos
/// que requieren rol ADMIN.
class AdminRepository {
  final DioClient _client;

  AdminRepository(this._client);

  // ─────────── USUARIOS ───────────

  /// Devuelve todos los usuarios del sistema con datos completos para admin.
  /// Vienen ordenados activos primero, después bloqueados, alfabéticamente.
  Future<List<UsuarioAdmin>> listarUsuarios() async {
    try {
      final response = await _client.dio.get('/admin/usuarios');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => UsuarioAdmin.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapearError(e, 'Error al listar usuarios');
    }
  }

  /// Bloquea un usuario guardando el motivo. Cierra sus sesiones activas.
  Future<void> bloquearUsuario(int usuarioId, String motivo) async {
    try {
      await _client.dio.delete('/admin/usuarios/$usuarioId',
          data: {'motivo': motivo});
    } on DioException catch (e) {
      _mapearError(e, 'Error al bloquear el usuario');
    }
  }

  /// Desbloquea un usuario previamente bloqueado.
  Future<void> desbloquearUsuario(int usuarioId) async {
    try {
      await _client.dio.put('/admin/usuarios/$usuarioId/desbloquear');
    } on DioException catch (e) {
      _mapearError(e, 'Error al desbloquear el usuario');
    }
  }

  /// Crea un nuevo usuario con rol ADMIN.
  Future<UsuarioAdmin> crearAdmin({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post('/admin/usuarios', data: {
        'nombre': nombre,
        'email': email,
        'password': password,
      });
      return UsuarioAdmin.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapearError(e, 'Error al crear el admin');
    }
  }

  /// Resetea la contraseña de un usuario sin verificar la actual.
  Future<void> resetearContrasena(int usuarioId, String nuevaPassword) async {
    try {
      await _client.dio.put('/admin/usuarios/$usuarioId/resetear-contrasena',
          data: {'newPassword': nuevaPassword});
    } on DioException catch (e) {
      _mapearError(e, 'Error al resetear la contraseña');
    }
  }

  // ─────────── CONSEJOS ───────────

  /// Devuelve todos los consejos (incluye inactivos y futuros).
  Future<List<Consejo>> listarConsejos() async {
    try {
      final response = await _client.dio.get('/admin/recursos');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => Consejo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapearError(e, 'Error al listar los consejos');
    }
  }

  /// Crea un consejo nuevo. La fechaPublicacion es opcional pero, si se indica,
  /// debe estar libre (el servidor valida la unicidad).
  Future<Consejo> crearConsejo({
    required String titulo,
    required String descripcion,
    DateTime? fechaPublicacion,
    bool activo = true,
  }) async {
    try {
      final response = await _client.dio.post('/admin/recursos', data: {
        'titulo': titulo,
        'descripcion': descripcion,
        if (fechaPublicacion != null)
          'fechaPublicacion': _formatearFecha(fechaPublicacion),
        'activo': activo,
      });
      return Consejo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapearError(e, 'Error al crear el consejo');
    }
  }

  /// Edita un consejo existente.
  Future<Consejo> editarConsejo(
    int id, {
    required String titulo,
    required String descripcion,
    DateTime? fechaPublicacion,
    required bool activo,
  }) async {
    try {
      final response = await _client.dio.put('/admin/recursos/$id', data: {
        'titulo': titulo,
        'descripcion': descripcion,
        if (fechaPublicacion != null)
          'fechaPublicacion': _formatearFecha(fechaPublicacion),
        'activo': activo,
      });
      return Consejo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapearError(e, 'Error al editar el consejo');
    }
  }

  /// Elimina físicamente un consejo.
  Future<void> eliminarConsejo(int id) async {
    try {
      await _client.dio.delete('/admin/recursos/$id');
    } on DioException catch (e) {
      _mapearError(e, 'Error al eliminar el consejo');
    }
  }

  // ─────────── MÉTRICAS ───────────

  /// Devuelve el snapshot de métricas globales del panel admin.
  Future<MetricasAdmin> obtenerMetricas() async {
    try {
      final response = await _client.dio.get('/admin/metricas');
      return MetricasAdmin.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapearError(e, 'Error al obtener las métricas');
    }
  }

  // ─────────── AUDIT LOG ───────────

  /// Devuelve los últimos 100 registros de auditoría globales.
  Future<List<AuditLog>> listarAuditLog() async {
    try {
      final response = await _client.dio.get('/admin/audit');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapearError(e, 'Error al obtener el audit log');
    }
  }

  /// Devuelve los últimos 100 registros de auditoría de un usuario concreto.
  Future<List<AuditLog>> listarAuditPorUsuario(int usuarioId) async {
    try {
      final response = await _client.dio.get('/admin/audit/usuario/$usuarioId');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _mapearError(e, 'Error al obtener el audit del usuario');
    }
  }

  // ─────────── HELPERS ───────────

  String _formatearFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  /// Caso especial admin: la API puede devolver 400 con un mensaje en el
  /// cuerpo (mapa de errores de validación o string) que queremos propagar
  /// al panel para mostrarlo al usuario. También trata 403 como un 401
  /// porque el panel solo se muestra a admins: si no autorizan algo, la
  /// sesión ya no es válida.
  Never _mapearError(DioException e, String mensajeGenerico) {
    final status = e.response?.statusCode;
    if (status == 400) {
      final body = e.response?.data;
      if (body is Map && body.values.isNotEmpty) {
        throw BadRequestException(body.values.first?.toString() ?? mensajeGenerico);
      }
      if (body is String && body.isNotEmpty) throw BadRequestException(body);
      throw BadRequestException(mensajeGenerico);
    }
    if (status == 403) throw UnauthorizedException();
    handleDioError(e, mensajeGenerico);
  }
}
