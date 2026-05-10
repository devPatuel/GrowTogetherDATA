import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('UsuarioAdmin.fromJson', () {
    test('mapea un usuario activo con todos los campos', () {
      final u = UsuarioAdmin.fromJson({
        'id': 5,
        'nombre': 'Jordi',
        'email': 'jordi@growtogether.com',
        'rol': 'USUARIO',
        'fechaRegistro': '2026-01-15T08:00:00.000',
        'puntosTotales': 320,
        'foto': null,
        'activo': true,
        'motivoBloqueo': null,
        'fechaBloqueo': null,
      });

      expect(u.id, 5);
      expect(u.activo, isTrue);
      expect(u.fechaRegistro?.year, 2026);
      expect(u.motivoBloqueo, isNull);
    });

    test('mapea un usuario bloqueado con motivo y fecha', () {
      final u = UsuarioAdmin.fromJson({
        'id': 9,
        'nombre': 'Spammer',
        'email': 'spam@example.com',
        'activo': false,
        'motivoBloqueo': 'Comportamiento abusivo',
        'fechaBloqueo': '2026-04-30T12:00:00.000',
      });

      expect(u.activo, isFalse);
      expect(u.motivoBloqueo, 'Comportamiento abusivo');
      expect(u.fechaBloqueo?.day, 30);
    });
  });
}
