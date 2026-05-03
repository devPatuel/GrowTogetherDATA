/// Representación completa de un usuario para uso del panel admin.
///
/// Incluye los campos sensibles que el modelo {@link Usuario} de la app oculta:
/// estado de bloqueo, motivo y fecha. Solo se obtiene desde endpoints /admin.
class UsuarioAdmin {
  final int id;
  final String nombre;
  final String email;
  final String? rol;
  final DateTime? fechaRegistro;
  final int puntosTotales;
  final String? foto;
  final bool activo;
  final String? motivoBloqueo;
  final DateTime? fechaBloqueo;

  UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol,
    this.fechaRegistro,
    this.puntosTotales = 0,
    this.foto,
    this.activo = true,
    this.motivoBloqueo,
    this.fechaBloqueo,
  });

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    return UsuarioAdmin(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rol: json['rol'] as String?,
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'] as String)
          : null,
      puntosTotales: json['puntosTotales'] as int? ?? 0,
      foto: json['foto'] as String?,
      activo: json['activo'] as bool? ?? true,
      motivoBloqueo: json['motivoBloqueo'] as String?,
      fechaBloqueo: json['fechaBloqueo'] != null
          ? DateTime.parse(json['fechaBloqueo'] as String)
          : null,
    );
  }
}
