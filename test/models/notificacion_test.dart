import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Notificacion.fromJson', () {
    test('parsea horaProgramada con formato HH:mm:ss', () {
      final noti = Notificacion.fromJson({
        'id': 5,
        'mensaje': 'Hora de leer',
        'horaProgramada': '08:30:00',
        'activa': true,
        'habitoId': 12,
      });

      expect(noti.id, 5);
      expect(noti.hora, 8);
      expect(noti.minuto, 30);
      expect(noti.activa, isTrue);
      expect(noti.habitoId, 12);
    });

    test('cae a 00:00 si horaProgramada es nula o malformada', () {
      final noti = Notificacion.fromJson({
        'id': 1,
        'mensaje': '',
        'horaProgramada': null,
        'habitoId': 1,
      });

      expect(noti.hora, 0);
      expect(noti.minuto, 0);
    });
  });

  group('Notificacion.horaFormateada', () {
    test('rellena con ceros y añade segundos a 00', () {
      final noti = Notificacion(
        id: 1,
        mensaje: '',
        hora: 7,
        minuto: 5,
        habitoId: 1,
      );

      expect(noti.horaFormateada, '07:05:00');
    });
  });

  group('Notificacion.copyWith', () {
    test('cambia solo los campos indicados', () {
      final original = Notificacion(
        id: 1,
        mensaje: 'Original',
        hora: 8,
        minuto: 0,
        activa: true,
        habitoId: 1,
      );

      final copia = original.copyWith(activa: false, mensaje: 'Cambiado');

      expect(copia.id, 1);
      expect(copia.hora, 8);
      expect(copia.activa, isFalse);
      expect(copia.mensaje, 'Cambiado');
    });
  });
}
