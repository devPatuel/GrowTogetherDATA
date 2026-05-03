import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Usuario.fromJson', () {
    test('mapea todos los campos cuando vienen completos', () {
      final usuario = Usuario.fromJson({
        'id': 12,
        'nombre': 'Jordi',
        'email': 'jordi@example.com',
        'foto': 'avatar.png',
        'rol': 'ADMIN',
        'puntosTotales': 540,
        'tema': 'oscuro',
        'idioma': 'es',
      });

      expect(usuario.id, 12);
      expect(usuario.nombre, 'Jordi');
      expect(usuario.email, 'jordi@example.com');
      expect(usuario.rol, 'ADMIN');
      expect(usuario.puntosTotales, 540);
    });

    test('acepta el alias usuarioId cuando no hay id', () {
      final usuario = Usuario.fromJson({
        'usuarioId': 99,
        'nombre': 'Alias',
        'email': 'alias@example.com',
      });

      expect(usuario.id, 99);
    });
  });
}
