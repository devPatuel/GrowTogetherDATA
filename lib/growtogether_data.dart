/// Capa de datos compartida de GrowTogether.
///
/// Reúne modelos del dominio, cliente HTTP, almacenamiento seguro y
/// repositorios que consumen la API. Pensado para ser usado tanto por la
/// app móvil como por el panel de administración.
library;

// API
export 'src/api/api_config.dart';
export 'src/api/api_exceptions.dart';
export 'src/api/auth_interceptor.dart';
export 'src/api/dio_client.dart';

// Local
export 'src/local/secure_storage_service.dart';

// Modelos
export 'src/models/audit_log.dart';
export 'src/models/consejo.dart';
export 'src/models/desafio.dart';
export 'src/models/habito.dart';
export 'src/models/metricas_admin.dart';
export 'src/models/participante_desafio.dart';
export 'src/models/registro_desafio.dart';
export 'src/models/registro_historial.dart';
export 'src/models/solicitud_amistad.dart';
export 'src/models/usuario.dart';
export 'src/models/usuario_admin.dart';

// Repositorios
export 'src/repositories/admin_repository.dart';
export 'src/repositories/amistad_repository.dart';
export 'src/repositories/auth_repository.dart';
export 'src/repositories/consejo_repository.dart';
export 'src/repositories/desafio_repository.dart';
export 'src/repositories/habito_repository.dart';
export 'src/repositories/user_repository.dart';
