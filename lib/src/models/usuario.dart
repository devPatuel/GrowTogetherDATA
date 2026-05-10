/// Modelo de usuario para la app cliente.
///
/// Solo expone los campos que la app móvil necesita ver de su propio perfil
/// o del de otros usuarios visibles. Para el panel de administración existe
/// [UsuarioAdmin], que añade campos sensibles (estado de bloqueo, motivo,
/// fecha) que no deben llegar a la app cliente.
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? foto;
  final String? rol;
  final int puntosTotales;
  final String? tema;
  final String? idioma;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.foto,
    this.rol,
    this.puntosTotales = 0,
    this.tema,
    this.idioma,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['usuarioId'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
      rol: json['rol'],
      puntosTotales: json['puntosTotales'] ?? 0,
      tema: json['tema'],
      idioma: json['idioma'],
    );
  }
}
