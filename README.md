# GrowTogether DATA

> Capa de datos compartida del ecosistema **GrowTogether**: modelos, cliente HTTP, almacenamiento seguro y repositorios que consumen la API REST.

![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-package-02569B?logo=flutter&logoColor=white)
![Dio](https://img.shields.io/badge/HTTP-Dio%205.x-1E88E5)
![Versión](https://img.shields.io/badge/versi%C3%B3n-0.5.0-4CAF50)

---

## Sobre el proyecto

**GrowTogether** es una aplicación de seguimiento de hábitos con componente social, inspirada en *Atomic Habits* de James Clear: construye hábitos consistentes, visualiza tu progreso y compite con amigos en desafíos.

Es el **Trabajo Final de Grado de DAM** (Desarrollo de Aplicaciones Multiplataforma, 2025/2026) de **Jordi Patuel Pons**.

### Papel de este repositorio

Paquete Dart/Flutter que importan tanto la **app móvil** (`GrowTogetherAPP`) como el **panel de administración web** (`GrowTogetherADMIN`): un único punto de verdad para modelos, cliente HTTP (Dio + interceptor JWT), almacenamiento seguro y repositorios contra la API.

## Ecosistema GrowTogether

| Repositorio | Descripción |
|---|---|
| [GrowTogetherAPI](https://github.com/devPatuel/GrowTogetherAPI) | Backend REST (Java 17 + Spring Boot) |
| [GrowTogetherAPP](https://github.com/devPatuel/GrowTogetherAPP) | App móvil de hábitos (Flutter) |
| [GrowTogetherADMIN](https://github.com/devPatuel/GrowTogetherADMIN) | Panel de administración web (Flutter Web) |
| **[GrowTogetherDATA](https://github.com/devPatuel/GrowTogetherDATA)** ← estás aquí | Paquete Dart compartido: modelos, cliente HTTP y repositorios |

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

## Stack técnico

| Capa | Tecnología |
|------|-----------|
| Lenguaje | Dart (SDK ^3.10.4), paquete Flutter |
| HTTP | Dio 5.x + interceptor JWT propio |
| Almacenamiento seguro | `flutter_secure_storage` 9.x |
| Tests | `flutter_test` + `mocktail` |
| Versionado | Tags git (`vX.Y.Z`), consumido por git ref desde las apps |

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
    │   ├── notificacion.dart               Recordatorio asociado a un hábito
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
        ├── notificacion_repository.dart    CRUD de recordatorios
        └── user_repository.dart
```

---

## Uso desde una app

En desarrollo local se consume por **path** (cambios al instante sin publicar):

```yaml
# pubspec.yaml de la app que lo consume
dependencies:
  growtogether_data:
    path: ../GrowTogetherDATA
```

En CI y producción se consume por **git + tag** para fijar una versión concreta:

```yaml
dependencies:
  growtogether_data:
    git:
      url: https://github.com/devPatuel/GrowTogetherDATA.git
      ref: v0.5.0
```

El truco habitual es tener `pubspec_overrides.yaml` con el `path` en local y
borrarlo en CI (lo hace el workflow), de modo que el `pubspec.yaml` siempre
queda con el `git: ref: vX.Y.Z` que se entrega.

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

## Ejecutar en local (desarrollo del paquete)

```bash
flutter pub get
flutter analyze
flutter test
```

Al ser una librería no hay app que lanzar: se desarrolla apuntando desde
`GrowTogetherAPP` o `GrowTogetherADMIN` con un `pubspec_overrides.yaml`
(`path: ../GrowTogetherDATA`) y probando los cambios desde esas apps
contra la [API](https://github.com/devPatuel/GrowTogetherAPI) en local.

---

## Decisiones de arquitectura

Las decisiones que afectan al paquete (Dio como cliente HTTP, `flutter_secure_storage`
para credenciales, modelos separados `Usuario`/`UsuarioAdmin` por audiencia, versionado
por tags git, etc.) están documentadas en [`docs/DECISIONS.md`](docs/DECISIONS.md).

---

## Generar documentación (`dart doc`)

```bash
dart doc .
```

Salida en `doc/api/`. Por defecto está incluida en `.gitignore` (quita la línea
`**/doc/api/` si quieres versionarla o publicarla a GitHub Pages).

---

## Licencia

Proyecto académico — Trabajo Final de Grado de DAM · GrowTogether · Jordi Patuel Pons.
