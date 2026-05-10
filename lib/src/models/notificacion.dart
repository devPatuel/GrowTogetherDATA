/// Recordatorio asociado a un hábito.
///
/// La hora se guarda como dos enteros (hora y minuto) en lugar de un
/// `DateTime` porque la API la persiste como `java.sql.Time` (solo hora,
/// sin fecha) y se serializa como string `"HH:mm:ss"`.
///
/// La frecuencia real con la que la noti se dispara la decide el cliente
/// derivándola del hábito asociado: diaria si el hábito es DIARIO, o
/// limitada a sus `diasSemana` si es PERSONALIZADO. El backend mantiene
/// internamente un campo `frecuencia` por compatibilidad histórica, pero
/// el cliente lo ignora.
class Notificacion {
  final int id;
  final String mensaje;
  final int hora;
  final int minuto;
  final bool activa;
  final int habitoId;

  Notificacion({
    required this.id,
    required this.mensaje,
    required this.hora,
    required this.minuto,
    this.activa = true,
    required this.habitoId,
  });

  /// Hora formateada como `"HH:mm:ss"` tal y como la espera la API.
  String get horaFormateada =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}:00';

  Notificacion copyWith({
    int? id,
    String? mensaje,
    int? hora,
    int? minuto,
    bool? activa,
    int? habitoId,
  }) {
    return Notificacion(
      id: id ?? this.id,
      mensaje: mensaje ?? this.mensaje,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
      activa: activa ?? this.activa,
      habitoId: habitoId ?? this.habitoId,
    );
  }

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    final raw = json['horaProgramada']?.toString() ?? '00:00:00';
    final partes = raw.split(':');
    final h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return Notificacion(
      id: json['id'] as int,
      mensaje: json['mensaje'] as String? ?? '',
      hora: h,
      minuto: m,
      activa: json['activa'] as bool? ?? true,
      habitoId: json['habitoId'] as int,
    );
  }
}
