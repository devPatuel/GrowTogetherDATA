import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('RegistroDesafio.fromJson', () {
    test('mapea un registro completado con puntos', () {
      final reg = RegistroDesafio.fromJson({
        'usuarioId': 7,
        'fecha': '2026-05-10T00:00:00.000',
        'estado': 'COMPLETADO',
        'puntosGanados': 50,
      });

      expect(reg.usuarioId, 7);
      expect(reg.estado, 'COMPLETADO');
      expect(reg.completado, isTrue);
      expect(reg.noCompletado, isFalse);
      expect(reg.pendiente, isFalse);
      expect(reg.puntosGanados, 50);
    });

    test('aplica default PENDIENTE si falta estado', () {
      final reg = RegistroDesafio.fromJson({
        'fecha': '2026-05-10T00:00:00.000',
      });

      expect(reg.estado, 'PENDIENTE');
      expect(reg.pendiente, isTrue);
      expect(reg.puntosGanados, 0);
    });
  });
}
