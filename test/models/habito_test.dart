import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Habito.fromJson', () {
    test('mapea todos los campos de un hábito completo', () {
      final habito = Habito.fromJson({
        'id': 5,
        'nombre': 'Leer',
        'descripcion': '20 min al día',
        'rachaActual': 3,
        'rachaMaxima': 10,
        'usuarioId': 1,
        'completadoHoy': true,
        'frecuencia': 'SEMANAL',
        'diasSemana': ['LUNES', 'MIERCOLES'],
        'tipo': 'POSITIVO',
        'icono': 'book',
        'fechaInicio': '2026-04-01T00:00:00.000',
        'progresoMensual': 0.65,
      });

      expect(habito.id, 5);
      expect(habito.nombre, 'Leer');
      expect(habito.rachaActual, 3);
      expect(habito.completadoHoy, isTrue);
      expect(habito.diasSemana, {'LUNES', 'MIERCOLES'});
      expect(habito.fechaInicio, isNotNull);
      expect(habito.progresoMensual, 0.65);
    });

    test('esNegativo distingue tipo NEGATIVO de POSITIVO', () {
      final negativo = Habito.fromJson({
        'id': 1,
        'nombre': 'Fumar',
        'descripcion': '',
        'usuarioId': 1,
        'tipo': 'NEGATIVO',
      });
      final positivo = Habito.fromJson({
        'id': 2,
        'nombre': 'Andar',
        'descripcion': '',
        'usuarioId': 1,
        'tipo': 'POSITIVO',
      });

      expect(negativo.esNegativo, isTrue);
      expect(positivo.esNegativo, isFalse);
    });
  });
}
