/// Registro de auditoría de una acción administrativa.
///
/// Solo se consume desde el panel admin. No expone el password ni datos
/// sensibles del usuario afectado, solo IDs y descripciones textuales.
class AuditLog {
  final int id;
  final String accion;
  final String entidad;
  final int? entidadId;
  final int usuarioId;
  final String? usuarioEmail;
  final String? detalle;
  final String? ip;
  final DateTime fecha;

  AuditLog({
    required this.id,
    required this.accion,
    required this.entidad,
    this.entidadId,
    required this.usuarioId,
    this.usuarioEmail,
    this.detalle,
    this.ip,
    required this.fecha,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as int,
      accion: json['accion'] as String? ?? '',
      entidad: json['entidad'] as String? ?? '',
      entidadId: json['entidadId'] as int?,
      usuarioId: json['usuarioId'] as int,
      usuarioEmail: json['usuarioEmail'] as String?,
      detalle: json['detalle'] as String?,
      ip: json['ip'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }
}
