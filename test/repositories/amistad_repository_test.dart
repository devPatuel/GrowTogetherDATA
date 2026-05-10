import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late AmistadRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = AmistadRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> usuarioJson({int id = 1}) => {
        'id': id,
        'nombre': 'Jordi',
        'email': 'jordi@growtogether.com',
        'puntosTotales': 0,
      };

  test('listarAmigos devuelve la lista', () async {
    final options = opts('/usuarios/amigos');
    when(() => dio.get('/usuarios/amigos')).thenAnswer(
      (_) async => respuesta(options, [usuarioJson(id: 2), usuarioJson(id: 3)], 200),
    );

    final amigos = await repo.listarAmigos();

    expect(amigos, hasLength(2));
  });

  test('buscarPorId devuelve null cuando la API responde 404', () async {
    final options = opts('/usuarios/publico/999');
    when(() => dio.get('/usuarios/publico/999')).thenThrow(
      DioException(requestOptions: options, response: respuesta(options, null, 404)),
    );

    expect(await repo.buscarPorId(999), isNull);
  });

  test('enviarSolicitud propaga BadRequestException con mensaje de la API', () async {
    final options = opts('/usuarios/amistades/solicitudes/5');
    when(() => dio.post('/usuarios/amistades/solicitudes/5')).thenThrow(
      DioException(
        requestOptions: options,
        response: respuesta(options, {'message': 'Ya sois amigos'}, 400),
      ),
    );

    expect(
      () => repo.enviarSolicitud(5),
      throwsA(isA<BadRequestException>()
          .having((e) => e.message, 'message', 'Ya sois amigos')),
    );
  });
}
