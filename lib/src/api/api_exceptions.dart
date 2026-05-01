class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'No autorizado']) : super(statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Error de conexión']);
}

class ServerException extends ApiException {
  ServerException([super.message = 'Error del servidor']) : super(statusCode: 500);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message) : super(statusCode: 400);
}
