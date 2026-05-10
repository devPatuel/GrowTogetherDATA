import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late ConsejoRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = ConsejoRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  test('obtenerConsejoDeHoy devuelve el consejo cuando la API responde 200', () async {
    final options = opts('/usuarios/consejo/hoy');
    when(() => dio.get('/usuarios/consejo/hoy')).thenAnswer(
      (_) async => respuesta(options, {
        'id': 7,
        'titulo': 'Bebe agua',
        'descripcion': 'Mantente hidratado',
      }, 200),
    );

    final consejo = await repo.obtenerConsejoDeHoy();

    expect(consejo, isNotNull);
    expect(consejo!.titulo, 'Bebe agua');
  });

  test('obtenerConsejoDeHoy devuelve null cuando la API responde 204', () async {
    final options = opts('/usuarios/consejo/hoy');
    when(() => dio.get('/usuarios/consejo/hoy')).thenAnswer(
      (_) async => respuesta(options, null, 204),
    );

    expect(await repo.obtenerConsejoDeHoy(), isNull);
  });

  test('obtenerConsejoDeHoy lanza NetworkException si no hay conexión', () async {
    final options = opts('/usuarios/consejo/hoy');
    when(() => dio.get('/usuarios/consejo/hoy')).thenThrow(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );

    expect(repo.obtenerConsejoDeHoy(), throwsA(isA<NetworkException>()));
  });
}
