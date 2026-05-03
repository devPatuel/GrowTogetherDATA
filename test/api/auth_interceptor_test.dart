import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements SecureStorageService {}

class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? capturado;
  @override
  void next(RequestOptions options) {
    capturado = options;
  }
}

class _ErrorHandler extends ErrorInterceptorHandler {
  DioException? capturado;
  @override
  void next(DioException err) {
    capturado = err;
  }
}

void main() {
  late _MockStorage storage;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = _MockStorage();
    interceptor = AuthInterceptor(storage);
  });

  test('onRequest añade Authorization Bearer cuando hay token', () async {
    when(() => storage.getToken()).thenAnswer((_) async => 'abc.def.ghi');
    final options = RequestOptions(path: '/habitos');
    final handler = _CapturingHandler();

    interceptor.onRequest(options, handler);
    await Future<void>.delayed(Duration.zero);

    expect(handler.capturado!.headers['Authorization'], 'Bearer abc.def.ghi');
    expect(handler.capturado!.headers['Content-Type'], 'application/json');
  });

  test('onRequest no añade Authorization cuando no hay token guardado', () async {
    when(() => storage.getToken()).thenAnswer((_) async => null);
    final options = RequestOptions(path: '/auth/login');
    final handler = _CapturingHandler();

    interceptor.onRequest(options, handler);
    await Future<void>.delayed(Duration.zero);

    expect(handler.capturado!.headers.containsKey('Authorization'), isFalse);
  });

  test('onError borra el almacenamiento cuando la respuesta es 401', () {
    when(() => storage.deleteAll()).thenAnswer((_) async {});
    final options = RequestOptions(path: '/habitos');
    final err = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );

    interceptor.onError(err, _ErrorHandler());

    verify(() => storage.deleteAll()).called(1);
  });
}
