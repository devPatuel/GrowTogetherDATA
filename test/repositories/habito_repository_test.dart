import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late HabitoRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = HabitoRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> habitoJson({int id = 1, String nombre = 'Leer'}) => {
        'id': id,
        'nombre': nombre,
        'descripcion': '',
        'usuarioId': 1,
      };

  test('getHabitos devuelve la lista de hábitos del usuario', () async {
    final options = opts('/habitos/usuario/1');
    when(() => dio.get(
          '/habitos/usuario/1',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => respuesta(
          options,
          [habitoJson(id: 1), habitoJson(id: 2, nombre: 'Andar')],
          200,
        ));

    final habitos = await repo.getHabitos(1);

    expect(habitos, hasLength(2));
    expect(habitos.last.nombre, 'Andar');
  });

  test('getHabitos lanza UnauthorizedException si la API devuelve 401', () async {
    final options = opts('/habitos/usuario/1');
    when(() => dio.get(any(), queryParameters: any(named: 'queryParameters')))
        .thenThrow(DioException(
      requestOptions: options,
      response: respuesta(options, null, 401),
    ));

    expect(() => repo.getHabitos(1), throwsA(isA<UnauthorizedException>()));
  });

  test('crearHabito envía los datos y devuelve el hábito creado', () async {
    final options = opts('/habitos');
    when(() => dio.post('/habitos', data: any(named: 'data'))).thenAnswer(
      (_) async => respuesta(options, habitoJson(id: 99, nombre: 'Meditar'), 201),
    );

    final h = await repo.crearHabito(nombre: 'Meditar', descripcion: '5 min');

    expect(h.id, 99);
    expect(h.nombre, 'Meditar');
  });

  test('crearHabito lanza BadRequestException con mensaje del backend (400)', () async {
    final options = opts('/habitos');
    when(() => dio.post('/habitos', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        response: respuesta(options, {'nombre': 'El nombre no puede estar vacío'}, 400),
      ),
    );

    expect(
      () => repo.crearHabito(nombre: '', descripcion: ''),
      throwsA(isA<BadRequestException>()
          .having((e) => e.message, 'message', 'El nombre no puede estar vacío')),
    );
  });
}
