import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late AdminRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = AdminRepository(client);
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  Map<String, dynamic> usuarioAdminJson({int id = 1, bool activo = true}) => {
        'id': id,
        'nombre': 'Jordi',
        'email': 'jordi@growtogether.com',
        'rol': 'USUARIO',
        'activo': activo,
      };

  test('listarUsuarios devuelve la lista de UsuarioAdmin', () async {
    final options = opts('/admin/usuarios');
    when(() => dio.get('/admin/usuarios')).thenAnswer(
      (_) async => respuesta(options, [
        usuarioAdminJson(id: 1, activo: true),
        usuarioAdminJson(id: 2, activo: false),
      ], 200),
    );

    final lista = await repo.listarUsuarios();

    expect(lista, hasLength(2));
    expect(lista.last.activo, isFalse);
  });

  test('bloquearUsuario propaga BadRequestException con mensaje de la API', () async {
    final options = opts('/admin/usuarios/3');
    when(() => dio.delete('/admin/usuarios/3', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        response: respuesta(options, {'motivo': 'El motivo es obligatorio'}, 400),
      ),
    );

    expect(
      () => repo.bloquearUsuario(3, ''),
      throwsA(isA<BadRequestException>()
          .having((e) => e.message, 'message', 'El motivo es obligatorio')),
    );
  });

  test('403 se mapea a UnauthorizedException porque rol no autorizado', () async {
    final options = opts('/admin/metricas');
    when(() => dio.get('/admin/metricas')).thenThrow(
      DioException(requestOptions: options, response: respuesta(options, null, 403)),
    );

    expect(repo.obtenerMetricas(), throwsA(isA<UnauthorizedException>()));
  });
}
