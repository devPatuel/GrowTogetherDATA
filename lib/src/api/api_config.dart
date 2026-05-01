/// Configuración de acceso a la API REST.
///
/// El módulo no decide la URL por defecto: cada aplicación que lo consuma
/// (app móvil, panel admin) construye su propia [ApiConfig] indicando la
/// `baseUrl` que corresponda al entorno (local, dev, producción...).
class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  /// Crea una [ApiConfig] leyendo `--dart-define=API_URL=...`.
  /// Si la variable no está definida, usa el [fallback] que pase la app.
  factory ApiConfig.fromEnv({
    required String fallback,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    const envUrl = String.fromEnvironment('API_URL');
    return ApiConfig(
      baseUrl: envUrl.isNotEmpty ? envUrl : fallback,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }
}
