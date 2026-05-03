# growtogether_data

Capa de datos compartida del ecosistema **GrowTogether**: modelos, cliente HTTP,
almacenamiento seguro y repositorios que consumen la API REST.

Pensado como paquete Dart/Flutter local que importan tanto la **app móvil**
(`GrowTogetherAPP`) como el **panel de administración web** (`GrowTogetherADMIN`).
El backend (Spring Boot) vive en `GrowTogetherAPI`.

---

## Por qué un paquete aparte

El proyecto tiene dos clientes (móvil y web) que hablan con la misma API. En vez
de duplicar modelos y repositorios, los unifico aquí:

- Cualquier cambio en un endpoint solo se toca en este paquete.
- Los DTOs de la API se mapean una vez al modelo Dart y todos los clientes lo
  consumen igual.
- La app móvil expone solo lo que necesita (`Usuario`, `Habito`, `Desafio`...);
  el panel admin además tiene acceso a `UsuarioAdmin`, `AuditLog`,
  `MetricasAdmin` y `AdminRepository`.

---

## Contenido

```
lib/
├── growtogether_data.dart                  Barrel: exports públicos
└── src/
    ├── api/
    │   ├── api_config.dart                 ApiConfig.fromEnv (--dart-define API_URL)
    │   ├── api_exceptions.dart             ApiException, NetworkException, etc.
    │   ├── auth_interceptor.dart           Inyecta el JWT en cada petición
    │   └── dio_client.dart                 Wrapper de Dio + AuthInterceptor
    ├── local/
    │   └── secure_storage_service.dart     Persistencia del token y user info
    ├── models/
    │   ├── audit_log.dart
    │   ├── consejo.dart
    │   ├── desafio.dart
    │   ├── habito.dart
    │   ├── metricas_admin.dart             + NuevosUsuariosMes
    │   ├── participante_desafio.dart
    │   ├── registro_desafio.dart
    │   ├── registro_historial.dart
    │   ├── solicitud_amistad.dart
    │   ├── usuario.dart                    Modelo de cliente (app móvil)
    │   └── usuario_admin.dart              Modelo extendido (panel admin)
    └── repositories/
        ├── admin_repository.dart           CRUD usuarios/consejos/audit/métricas
        ├── amistad_repository.dart
        ├── auth_repository.dart            Login, register, logout
        ├── consejo_repository.dart         Cliente: consejo de hoy
        ├── desafio_repository.dart
        ├── habito_repository.dart
        └── user_repository.dart
```

---

## Uso desde una app

```yaml
# pubspec.yaml de la app que lo consume
dependencies:
  growtogether_data:
    path: ../GrowTogetherDATA
```

```dart
import 'package:growtogether_data/growtogether_data.dart';

final config = ApiConfig.fromEnv(fallback: 'http://localhost:8081/api/v1');
final storage = SecureStorageService();
final dio = DioClient(config, storage);

final auth = AuthRepository(dio, storage);
final usuarios = UserRepository(dio);
final consejos = ConsejoRepository(dio);

await auth.login('admin@growtogether.com', 'TuPassword1!');
final consejoHoy = await consejos.obtenerConsejoDeHoy();
```

La URL base se inyecta en compile time:

```bash
flutter run --dart-define=API_URL=https://tu-api.example.com/api/v1
```

---

## Convenciones

- **DTOs separados por audiencia.** `Usuario` (cliente) no expone `activo`,
  `motivoBloqueo` ni `fechaBloqueo`. Para el panel admin existe `UsuarioAdmin`
  con esos campos.
- **Repositorios delgados.** Solo mapean Dio → modelos y normalizan errores
  con las excepciones de `api_exceptions.dart`. Toda la lógica de negocio
  vive en el backend o en los `Provider` de cada app.
- **Sin estado mutable.** Los modelos son `final`. Los servicios (Dio,
  SecureStorage) se inyectan vía constructor; no hay singletons.
- **Castellano por defecto** en clases, métodos y comentarios, alineado con
  el resto del proyecto.

---

## Generar documentación API

```bash
dart doc .
```

Salida en `doc/api/`. Por defecto está incluida en `.gitignore` (quita la línea
`**/doc/api/` si quieres versionarla o publicarla a GitHub Pages).

---

## Tests

```bash
flutter test
```

---

## Licencia

Proyecto académico — GrowTogether (DAM, Jordi Patuel Pons).
