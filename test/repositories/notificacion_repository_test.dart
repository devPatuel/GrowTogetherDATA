import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late NotificacionRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = NotificacionRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> notiJson({int id = 1, int habitoId = 1}) => {
        'id': id,
        'mensaje': 'No te olvides',
        'horaProgramada': '08:30:00',
        'activa': true,
        'habitoId': habitoId,
      };

  test('listarPorHabito devuelve la lista del hábito', () async {
    final options = opts('/notificaciones/habito/3');
    when(() => dio.get('/notificaciones/habito/3')).thenAnswer(
      (_) async => respuesta(options, [notiJson(id: 1, habitoId: 3), notiJson(id: 2, habitoId: 3)], 200),
    );

    final lista = await repo.listarPorHabito(3);

    expect(lista, hasLength(2));
    expect(lista.first.habitoId, 3);
  });

  test('crear devuelve la notificación creada', () async {
    final options = opts('/notificaciones');
    when(() => dio.post('/notificaciones', data: any(named: 'data'))).thenAnswer(
      (_) async => respuesta(options, notiJson(id: 99, habitoId: 5), 201),
    );

    final n = await repo.crear(habitoId: 5, mensaje: 'Toca leer', hora: 9, minuto: 0);

    expect(n.id, 99);
    expect(n.habitoId, 5);
  });

  test('eliminar propaga UnauthorizedException si la API devuelve 401', () async {
    final options = opts('/notificaciones/1');
    when(() => dio.delete('/notificaciones/1')).thenThrow(
      DioException(requestOptions: options, response: respuesta(options, null, 401)),
    );

    expect(() => repo.eliminar(1), throwsA(isA<UnauthorizedException>()));
  });
}
