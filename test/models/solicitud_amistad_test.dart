import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('SolicitudAmistad.fromJson', () {
    test('mapea solicitud aceptada con fecha de respuesta', () {
      final s = SolicitudAmistad.fromJson({
        'id': 10,
        'remitenteId': 1,
        'remitenteNombre': 'Jordi',
        'destinatarioId': 2,
        'destinatarioNombre': 'Ana',
        'estado': 'ACEPTADA',
        'fechaEnvio': '2026-04-25T10:00:00.000',
        'fechaRespuesta': '2026-04-26T11:00:00.000',
      });

      expect(s.id, 10);
      expect(s.estado, 'ACEPTADA');
      expect(s.fechaRespuesta, isNotNull);
    });

    test('mapea solicitud pendiente sin fecha de respuesta', () {
      final s = SolicitudAmistad.fromJson({
        'id': 11,
        'remitenteId': 1,
        'remitenteNombre': 'Jordi',
        'destinatarioId': 3,
        'destinatarioNombre': 'Luis',
        'estado': 'PENDIENTE',
        'fechaEnvio': '2026-05-01T09:00:00.000',
      });

      expect(s.estado, 'PENDIENTE');
      expect(s.fechaRespuesta, isNull);
    });
  });
}
