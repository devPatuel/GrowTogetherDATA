import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late DesafioRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = DesafioRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> desafioJson({int id = 1}) => {
        'id': id,
        'nombre': 'Reto $id',
        'descripcion': '',
        'fechaInicio': '2026-05-01',
        'fechaFin': '2026-05-31',
        'creadorId': 1,
        'creadorNombre': 'Jordi',
      };

  test('listarMisDesafios devuelve la lista del usuario', () async {
    final options = opts('/desafios/mios');
    when(() => dio.get('/desafios/mios')).thenAnswer(
      (_) async => respuesta(options, [desafioJson(id: 1), desafioJson(id: 2)], 200),
    );

    final desafios = await repo.listarMisDesafios();

    expect(desafios, hasLength(2));
  });

  test('listarMisDesafios propaga UnauthorizedException si no hay token válido', () async {
    final options = opts('/desafios/mios');
    when(() => dio.get('/desafios/mios')).thenThrow(DioException(
      requestOptions: options,
      response: respuesta(options, null, 401),
    ));

    expect(() => repo.listarMisDesafios(), throwsA(isA<UnauthorizedException>()));
  });

  test('unirseADesafio devuelve el ParticipanteDesafio creado', () async {
    final options = opts('/desafios/9/unirse');
    when(() => dio.post('/desafios/9/unirse')).thenAnswer(
      (_) async => respuesta(options, {
        'id': 50,
        'usuarioId': 7,
        'usuarioNombre': 'Jordi',
        'desafioId': 9,
      }, 201),
    );

    final p = await repo.unirseADesafio(9);

    expect(p.id, 50);
    expect(p.desafioId, 9);
  });

  test('unirseADesafio lanza ApiException con el mensaje del backend si falla', () async {
    final options = opts('/desafios/9/unirse');
    when(() => dio.post('/desafios/9/unirse')).thenThrow(DioException(
      requestOptions: options,
      response: respuesta(options, {'message': 'Ya estás participando'}, 409),
    ));

    expect(
      () => repo.unirseADesafio(9),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Ya estás participando')),
    );
  });

  test('crearDesafio envía datos y devuelve el desafío creado', () async {
    final options = opts('/desafios');
    when(() => dio.post('/desafios', data: any(named: 'data')))
        .thenAnswer((_) async => respuesta(options, desafioJson(id: 100), 201));

    final desafio = await repo.crearDesafio(
      nombre: 'Reto 100',
      descripcion: 'Test',
      fechaInicio: DateTime(2026, 5, 1),
      fechaFin: DateTime(2026, 5, 31),
    );

    expect(desafio.id, 100);
  });
}
