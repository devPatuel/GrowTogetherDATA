import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late UserRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = UserRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> usuarioJson({int id = 1}) => {
        'id': id,
        'nombre': 'Jordi',
        'email': 'jordi@growtogether.com',
        'puntosTotales': 50,
      };

  test('obtenerPerfil devuelve el usuario', () async {
    final options = opts('/usuarios/perfil/1');
    when(() => dio.get('/usuarios/perfil/1')).thenAnswer(
      (_) async => respuesta(options, usuarioJson(id: 1), 200),
    );

    final u = await repo.obtenerPerfil(1);

    expect(u.id, 1);
    expect(u.nombre, 'Jordi');
  });

  test('obtenerPerfil lanza ApiException 404 si no existe', () async {
    final options = opts('/usuarios/perfil/99');
    when(() => dio.get('/usuarios/perfil/99')).thenThrow(
      DioException(requestOptions: options, response: respuesta(options, null, 404)),
    );

    expect(
      () => repo.obtenerPerfil(99),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
    );
  });

  test('cambiarContrasena lanza BadRequestException si la actual es incorrecta', () async {
    final options = opts('/usuarios/perfil/1/contrasena');
    when(() => dio.put('/usuarios/perfil/1/contrasena', data: any(named: 'data'))).thenThrow(
      DioException(requestOptions: options, response: respuesta(options, null, 400)),
    );

    expect(
      () => repo.cambiarContrasena(1, 'mal', 'NuevaPass1!'),
      throwsA(isA<BadRequestException>()),
    );
  });
}
