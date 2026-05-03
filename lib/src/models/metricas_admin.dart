import 'usuario_admin.dart';

/// Snapshot de métricas globales del panel admin.
///
/// Encapsula la respuesta de GET /admin/metricas para que el panel no manipule
/// el Map directamente.
class MetricasAdmin {
  final int totalUsuarios;
  final int usuariosActivos;
  final int totalHabitos;
  final int habitosCompletadosHoy;
  final int desafiosActivos;
  final UsuarioAdmin? usuarioMasVeterano;
  final List<NuevosUsuariosMes> usuariosNuevosPorMes;

  MetricasAdmin({
    required this.totalUsuarios,
    required this.usuariosActivos,
    required this.totalHabitos,
    required this.habitosCompletadosHoy,
    required this.desafiosActivos,
    this.usuarioMasVeterano,
    this.usuariosNuevosPorMes = const [],
  });

  factory MetricasAdmin.fromJson(Map<String, dynamic> json) {
    final veteranoJson = json['usuarioMasVeterano'];
    final nuevosJson = json['usuariosNuevosPorMes'] as List<dynamic>? ?? const [];
    return MetricasAdmin(
      totalUsuarios: (json['totalUsuarios'] as num?)?.toInt() ?? 0,
      usuariosActivos: (json['usuariosActivos'] as num?)?.toInt() ?? 0,
      totalHabitos: (json['totalHabitos'] as num?)?.toInt() ?? 0,
      habitosCompletadosHoy: (json['habitosCompletadosHoy'] as num?)?.toInt() ?? 0,
      desafiosActivos: (json['desafiosActivos'] as num?)?.toInt() ?? 0,
      usuarioMasVeterano: veteranoJson != null
          ? UsuarioAdmin.fromJson(veteranoJson as Map<String, dynamic>)
          : null,
      usuariosNuevosPorMes: nuevosJson
          .map((e) => NuevosUsuariosMes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Punto de la serie "nuevos usuarios por mes" (mes "YYYY-MM" + cantidad).
class NuevosUsuariosMes {
  final String mes;
  final int cantidad;

  NuevosUsuariosMes({required this.mes, required this.cantidad});

  factory NuevosUsuariosMes.fromJson(Map<String, dynamic> json) {
    return NuevosUsuariosMes(
      mes: json['mes'] as String,
      cantidad: (json['cantidad'] as num).toInt(),
    );
  }
}
