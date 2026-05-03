import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  test('UnauthorizedException tiene statusCode 401', () {
    final e = UnauthorizedException();
    expect(e.statusCode, 401);
    expect(e, isA<ApiException>());
  });

  test('BadRequestException conserva mensaje y devuelve 400', () {
    final e = BadRequestException('Email inválido');
    expect(e.statusCode, 400);
    expect(e.message, 'Email inválido');
    expect(e.toString(), 'Email inválido');
  });

  test('NetworkException no tiene statusCode (es de red, no HTTP)', () {
    final e = NetworkException();
    expect(e.statusCode, isNull);
    expect(e, isA<ApiException>());
  });
}
