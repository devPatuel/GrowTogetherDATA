import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';

void main() {
  group('Smoke test del barril growtogether_data', () {
    test('ApiConfig se construye con baseUrl explícita', () {
      const config = ApiConfig(baseUrl: 'http://localhost:8081/api/v1');
      expect(config.baseUrl, 'http://localhost:8081/api/v1');
      expect(config.connectTimeout, const Duration(seconds: 15));
      expect(config.receiveTimeout, const Duration(seconds: 15));
    });

    test('ApiConfig.fromEnv usa el fallback si no hay --dart-define=API_URL', () {
      final config = ApiConfig.fromEnv(fallback: 'http://fallback.test/api');
      expect(config.baseUrl, isNotEmpty);
    });

    test('Usuario.fromJson lee los campos opcionales sin romper', () {
      final usuario = Usuario.fromJson({
        'id': 7,
        'nombre': 'Jordi',
        'email': 'jordi@example.com',
        'tema': 'oscuro',
        'idioma': 'es',
      });
      expect(usuario.id, 7);
      expect(usuario.nombre, 'Jordi');
      expect(usuario.tema, 'oscuro');
      expect(usuario.idioma, 'es');
    });

    test('Las excepciones del módulo conservan statusCode coherente', () {
      expect(UnauthorizedException().statusCode, 401);
      expect(BadRequestException('msg').statusCode, 400);
      expect(ServerException().statusCode, 500);
    });
  });
}
