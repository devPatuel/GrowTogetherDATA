import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('ParticipanteDesafio.fromJson', () {
    test('mapea todos los campos y resuelve el estado SUPERADO', () {
      final p = ParticipanteDesafio.fromJson({
        'id': 1,
        'usuarioId': 7,
        'usuarioNombre': 'Jordi',
        'puntosGanadosEnDesafio': 120,
        'rachaActual': 5,
        'completadoHoy': true,
        'estadoProgreso': 'SUPERADO',
        'desafioId': 9,
      });

      expect(p.id, 1);
      expect(p.usuarioId, 7);
      expect(p.puntosGanados, 120);
      expect(p.completadoHoy, isTrue);
      expect(p.superado, isTrue);
      expect(p.activo, isFalse);
    });
  });
}
