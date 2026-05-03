import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Desafio.fromJson', () {
    test('parsea fechas en formato ISO y participantes anidados', () {
      final desafio = Desafio.fromJson({
        'id': 1,
        'nombre': '30 días sin azúcar',
        'descripcion': 'Reto colectivo',
        'fechaInicio': '2026-05-01',
        'fechaFin': '2026-05-31',
        'tipo': 'NEGATIVO',
        'creadorId': 7,
        'creadorNombre': 'Jordi',
        'participantes': [
          {'id': 1, 'usuarioId': 7, 'usuarioNombre': 'Jordi', 'desafioId': 1},
        ],
      });

      expect(desafio.id, 1);
      expect(desafio.fechaInicio, DateTime.parse('2026-05-01'));
      expect(desafio.participantes, hasLength(1));
      expect(desafio.esNegativo, isTrue);
    });

    test('parsea fechas en milisegundos epoch (formato Date Java)', () {
      final inicio = DateTime(2026, 5, 1).millisecondsSinceEpoch;
      final fin = DateTime(2026, 5, 31).millisecondsSinceEpoch;
      final desafio = Desafio.fromJson({
        'id': 2,
        'nombre': 'Reto',
        'descripcion': '',
        'fechaInicio': inicio,
        'fechaFin': fin,
        'creadorId': 1,
        'creadorNombre': 'Alguien',
      });

      expect(desafio.fechaInicio.millisecondsSinceEpoch, inicio);
      expect(desafio.fechaFin.millisecondsSinceEpoch, fin);
    });
  });
}
