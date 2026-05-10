import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('MetricasAdmin.fromJson', () {
    test('mapea métricas globales con usuario veterano y serie mensual', () {
      final metricas = MetricasAdmin.fromJson({
        'totalUsuarios': 120,
        'usuariosActivos': 100,
        'totalHabitos': 350,
        'habitosCompletadosHoy': 80,
        'desafiosActivos': 12,
        'usuarioMasVeterano': {
          'id': 1,
          'nombre': 'Jordi',
          'email': 'jordi@growtogether.com',
          'fechaRegistro': '2025-01-01T00:00:00.000',
        },
        'usuariosNuevosPorMes': [
          {'mes': '2026-04', 'cantidad': 15},
          {'mes': '2026-05', 'cantidad': 20},
        ],
      });

      expect(metricas.totalUsuarios, 120);
      expect(metricas.habitosCompletadosHoy, 80);
      expect(metricas.usuarioMasVeterano?.nombre, 'Jordi');
      expect(metricas.usuariosNuevosPorMes, hasLength(2));
      expect(metricas.usuariosNuevosPorMes.last.cantidad, 20);
    });

    test('campos numéricos faltantes caen a 0 y serie por mes a lista vacía', () {
      final metricas = MetricasAdmin.fromJson({});

      expect(metricas.totalUsuarios, 0);
      expect(metricas.habitosCompletadosHoy, 0);
      expect(metricas.usuarioMasVeterano, isNull);
      expect(metricas.usuariosNuevosPorMes, isEmpty);
    });
  });

  group('NuevosUsuariosMes.fromJson', () {
    test('mapea un punto de la serie', () {
      final p = NuevosUsuariosMes.fromJson({'mes': '2026-05', 'cantidad': 7});

      expect(p.mes, '2026-05');
      expect(p.cantidad, 7);
    });
  });
}
