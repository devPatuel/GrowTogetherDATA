/// Modelo de consejo de bienestar publicado por un admin.
///
/// La fechaPublicacion es opcional: cuando tiene valor, el consejo se muestra
/// ese día concreto en la app. Solo puede haber un consejo por fecha (validación
/// en el servidor).
class Consejo {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime? fechaPublicacion;
  final bool activo;
  final int? creadorId;

  Consejo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.fechaPublicacion,
    this.activo = true,
    this.creadorId,
  });

  factory Consejo.fromJson(Map<String, dynamic> json) {
    return Consejo(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.parse(json['fechaPublicacion'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
      creadorId: json['creadorId'] as int?,
    );
  }
}
