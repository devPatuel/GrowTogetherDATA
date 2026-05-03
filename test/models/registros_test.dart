import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  test('RegistroDesafio.fromJson mapea estado COMPLETADO con puntos', () {
    final r = RegistroDesafio.fromJson({
      'usuarioId': 7,
      'fecha': '2026-05-01',
      'estado': 'COMPLETADO',
      'puntosGanados': 25,
    });

    expect(r.usuarioId, 7);
    expect(r.estado, 'COMPLETADO');
    expect(r.puntosGanados, 25);
    expect(r.completado, isTrue);
  });

  test('RegistroHistorial.fromJson aplica default PENDIENTE si falta estado', () {
    final r = RegistroHistorial.fromJson({'fecha': '2026-05-02'});

    expect(r.estado, 'PENDIENTE');
    expect(r.pendiente, isTrue);
  });
}
