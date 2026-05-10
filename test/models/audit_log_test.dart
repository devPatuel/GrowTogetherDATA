import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('AuditLog.fromJson', () {
    test('mapea un registro completo', () {
      final log = AuditLog.fromJson({
        'id': 42,
        'accion': 'BLOQUEAR_USUARIO',
        'entidad': 'Usuario',
        'entidadId': 7,
        'usuarioId': 1,
        'usuarioEmail': 'admin@growtogether.com',
        'detalle': 'Spam reiterado',
        'ip': '10.0.0.1',
        'fecha': '2026-04-15T09:30:00.000',
      });

      expect(log.id, 42);
      expect(log.accion, 'BLOQUEAR_USUARIO');
      expect(log.entidad, 'Usuario');
      expect(log.entidadId, 7);
      expect(log.usuarioEmail, 'admin@growtogether.com');
      expect(log.fecha.year, 2026);
    });

    test('campos opcionales pueden ser null', () {
      final log = AuditLog.fromJson({
        'id': 1,
        'accion': 'LOGIN',
        'entidad': 'Usuario',
        'usuarioId': 1,
        'fecha': '2026-04-15T09:30:00.000',
      });

      expect(log.entidadId, isNull);
      expect(log.usuarioEmail, isNull);
      expect(log.detalle, isNull);
      expect(log.ip, isNull);
    });
  });
}
