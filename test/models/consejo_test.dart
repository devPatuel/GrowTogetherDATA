import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Consejo.fromJson', () {
    test('mapea un consejo con fecha de publicación', () {
      final consejo = Consejo.fromJson({
        'id': 3,
        'titulo': 'Bebe agua',
        'descripcion': 'Mantente hidratado',
        'fechaPublicacion': '2026-05-10',
        'activo': true,
        'creadorId': 1,
      });

      expect(consejo.id, 3);
      expect(consejo.titulo, 'Bebe agua');
      expect(consejo.fechaPublicacion?.day, 10);
      expect(consejo.activo, isTrue);
    });

    test('fechaPublicacion null cuando el consejo no está asignado a un día', () {
      final consejo = Consejo.fromJson({
        'id': 1,
        'titulo': 'Lee 10 minutos',
        'descripcion': '',
      });

      expect(consejo.fechaPublicacion, isNull);
      expect(consejo.activo, isTrue);
      expect(consejo.creadorId, isNull);
    });
  });
}
