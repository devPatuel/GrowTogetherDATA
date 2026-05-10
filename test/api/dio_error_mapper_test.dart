import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  RequestOptions opts() => RequestOptions(path: '/x');

  group('handleDioError', () {
    test('mapea 401 a UnauthorizedException', () {
      expect(
        () => handleDioError(
          DioException(
            requestOptions: opts(),
            response: Response(requestOptions: opts(), statusCode: 401),
          ),
          'fallback',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('mapea connectionError a NetworkException', () {
      expect(
        () => handleDioError(
          DioException(requestOptions: opts(), type: DioExceptionType.connectionError),
          'fallback',
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('mapea connectionTimeout a NetworkException', () {
      expect(
        () => handleDioError(
          DioException(requestOptions: opts(), type: DioExceptionType.connectionTimeout),
          'fallback',
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('mapea cualquier otro caso a ApiException con el mensaje genérico', () {
      expect(
        () => handleDioError(
          DioException(
            requestOptions: opts(),
            response: Response(requestOptions: opts(), statusCode: 500),
          ),
          'Error genérico',
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Error genérico')),
      );
    });
  });
}
