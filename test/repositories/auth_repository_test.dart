import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockDioClient extends Mock implements DioClient {}

class _MockDio extends Mock implements Dio {}

class _MockStorage extends Mock implements SecureStorageService {}

void main() {
  late _MockDioClient client;
  late _MockDio dio;
  late _MockStorage storage;
  late AuthRepository repo;

  setUp(() {
    client = _MockDioClient();
    dio = _MockDio();
    storage = _MockStorage();
    when(() => client.dio).thenReturn(dio);
    repo = AuthRepository(client, storage);

    when(() => storage.saveToken(any())).thenAnswer((_) async {});
    when(() => storage.saveUserId(any())).thenAnswer((_) async {});
    when(() => storage.saveUserName(any())).thenAnswer((_) async {});
    when(() => storage.saveUserEmail(any())).thenAnswer((_) async {});
    when(() => storage.deleteAll()).thenAnswer((_) async {});
  });

  RequestOptions opts(String path) => RequestOptions(path: path);
  Response<dynamic> respuesta(RequestOptions o, dynamic data, int code) =>
      Response<dynamic>(requestOptions: o, data: data, statusCode: code);

  test('login devuelve Usuario y guarda token + datos en storage', () async {
    final options = opts('/auth/login');
    when(() => dio.post('/auth/login', data: any(named: 'data'))).thenAnswer(
      (_) async => respuesta(options, {
        'token': 'jwt-token',
        'id': 7,
        'nombre': 'Jordi',
        'email': 'jordi@example.com',
      }, 200),
    );

    final usuario = await repo.login('jordi@example.com', 'secreto');

    expect(usuario.id, 7);
    verify(() => storage.saveToken('jwt-token')).called(1);
  });

  test('login lanza BadRequestException con credenciales incorrectas (401)', () async {
    final options = opts('/auth/login');
    when(() => dio.post('/auth/login', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        response: respuesta(options, null, 401),
      ),
    );

    expect(
      () => repo.login('mal@example.com', 'mal'),
      throwsA(isA<BadRequestException>()
          .having((e) => e.message, 'message', 'Credenciales incorrectas')),
    );
  });

  test('register lanza BadRequestException con email duplicado (409)', () async {
    final options = opts('/auth/registrar');
    when(() => dio.post('/auth/registrar', data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        response: respuesta(options, null, 409),
      ),
    );

    expect(
      () => repo.register('Jordi', 'duplicado@x.com', 'x'),
      throwsA(isA<BadRequestException>()
          .having((e) => e.message, 'message', 'El email ya está registrado')),
    );
  });

  test('logout borra todo del storage', () async {
    await repo.logout();
    verify(() => storage.deleteAll()).called(1);
  });

  test('getCurrentUser devuelve null si no hay datos guardados', () async {
    when(() => storage.getUserId()).thenAnswer((_) async => null);
    when(() => storage.getUserName()).thenAnswer((_) async => null);
    when(() => storage.getUserEmail()).thenAnswer((_) async => null);

    expect(await repo.getCurrentUser(), isNull);
  });
}
