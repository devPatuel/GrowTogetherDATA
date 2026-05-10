# Architecture Decision Records — GrowTogetherDATA

Decisiones de arquitectura específicas del paquete `growtogether_data`,
la capa de datos compartida entre la app móvil (`GrowTogetherAPP`) y el
panel de administración web (`GrowTogetherADMIN`).

**Proyecto**: GrowTogether — DAM 2026
**Autor**: Jordi Patuel Pons

> Este archivo documenta solo las decisiones que afectan al paquete DATA.
> Las decisiones del backend están en `GrowTogetherAPI/docs/DECISIONS.md`,
> las de la app móvil en `GrowTogetherAPP/docs/DECISIONS.md` y las del
> admin en `GrowTogetherADMIN/docs/DECISIONS.md`.

---

## Índice

| # | Decisión | Estado |
|---|----------|--------|
| [ADR-001](#adr-001-paquete-dart-compartido-en-vez-de-duplicar-modelos) | Paquete Dart compartido en vez de duplicar modelos | Aceptado |
| [ADR-002](#adr-002-dio-como-cliente-http) | Dio como cliente HTTP | Aceptado |
| [ADR-003](#adr-003-flutter_secure_storage-para-credenciales) | flutter_secure_storage para credenciales | Aceptado |
| [ADR-004](#adr-004-modelos-separados-por-audiencia-usuario-vs-usuarioadmin) | Modelos separados por audiencia (Usuario vs UsuarioAdmin) | Aceptado |
| [ADR-005](#adr-005-versionado-por-tags-git-y-consumo-pathgit-segun-entorno) | Versionado por tags git y consumo path/git según entorno | Aceptado |
| [ADR-006](#adr-006-rest-json-y-mapeo-en-repositorios-delgados) | REST/JSON y mapeo en repositorios delgados | Aceptado |
| [ADR-007](#adr-007-base64-para-fotos-de-perfil-en-el-modelo-usuario) | Base64 para fotos de perfil en el modelo Usuario | Aceptado (temporal) |
| [ADR-008](#adr-008-frecuencia-de-notificacin-derivada-del-hbito) | Frecuencia de notificación derivada del hábito | Aceptado |

---

## ADR-001: Paquete Dart compartido en vez de duplicar modelos

**Fecha**: 2026-03-01

### Contexto

El proyecto tiene dos clientes Flutter (app móvil y panel admin web) que
hablan con la misma API REST de Spring Boot. Cada cliente necesita
modelos del dominio (Usuario, Habito, Desafio…), un cliente HTTP, un
mecanismo de autenticación y los repositorios que mapean DTOs de la API
a esos modelos.

### Decisión

Extraer toda la capa de datos a un **paquete Dart local independiente**
(`growtogether_data`) y consumirlo desde APP y ADMIN como dependencia.

### Alternativas descartadas

**Duplicar modelos y repositorios en cada app**
La aproximación más simple al principio, pero condena a mantener dos
copias del mismo código. Cada cambio en un endpoint o un DTO obliga a
editar dos `lib/data/` con riesgo alto de divergencia.

**Generar los modelos desde OpenAPI**
SpringDoc publica un `openapi.json` que un generador Dart puede convertir
en modelos. Resultado idéntico pero con dos costes: (1) dependencia de
build-time del schema actualizado y (2) los nombres y dartdocs los
escribe la herramienta, no el desarrollador. Para un TFG con un dominio
estable se prefirió escribir los modelos a mano.

**Monorepo con un único `pubspec.yaml`**
Mover APP y ADMIN al mismo paquete y compartir `lib/data/`. Funciona
pero acopla las dependencias de Flutter web con las de Android, complica
los workflows de CI y obliga a coordinar despliegues.

### Razones de la decisión

1. **Una sola fuente de verdad**: los DTOs y la lógica de mapeo a
   modelos viven en un único repo. Cualquier cambio en la API se aplica
   aquí y los dos clientes se enteran al subir la versión.
2. **Versionado explícito**: cada APP/ADMIN se ancla a un tag de DATA
   (v0.3.0, v0.2.0…), de modo que un fallo en DATA no rompe a los
   clientes en producción hasta que decidan actualizar.
3. **Aislamiento de dependencias**: APP puede usar `image_picker` y
   `connectivity_plus` sin que ADMIN tenga que arrastrarlos.
4. **Test independiente**: la capa de datos se testea en su propio
   `flutter test` sin levantar la UI ni los providers.

### Consecuencias

- Cada cambio relevante en DATA requiere bumpear versión y crear un tag
  git (`v0.3.0` por ejemplo).
- En desarrollo local se consume con `path:` para tener cambios al
  instante; el workflow de CI borra el `pubspec_overrides.yaml` y usa
  el `git: ref: vX.Y.Z` del `pubspec.yaml`.
- Hay un overhead de gestión: sincronizar tres repos (DATA, APP, ADMIN)
  para una feature que toca el modelo. El beneficio compensa al evitar
  duplicar y desincronizar código.

---

## ADR-002: Dio como cliente HTTP

**Fecha**: 2026-03-01

### Contexto

Los repositorios necesitan un cliente HTTP que inyecte el JWT en cada
petición, gestione 401 globalmente y exponga errores tipados.

### Decisión

**Dio 5.x** envuelto en un `DioClient` con un `AuthInterceptor` propio.

### Alternativas descartadas

**Paquete `http` (oficial de Dart)**
Sin interceptores nativos: inyectar el JWT obligaría a envolver cada
método del repositorio en un helper, y manejar 401 globalmente
requeriría chequear la respuesta en cada llamada. Código repetitivo y
propenso a olvidos.

**Chopper / Retrofit for Dart**
Clientes con generación de código (`build_runner`). Funcionan bien pero
añaden setup que no compensa frente al enfoque imperativo de Dio en
proyectos de esta escala.

### Razones de la decisión

1. **Interceptores nativos**: `AuthInterceptor` centraliza
   `Authorization: Bearer …` y limpia credenciales ante un 401 en un
   único punto.
2. **API expresiva**: `dio.get`, `dio.post(data: …)`,
   `queryParameters` son ergonómicos para los repositorios.
3. **Errores tipados**: `DioException` distingue timeout, error de red
   y error HTTP por código, lo que el `_handleError` mapea a
   `NetworkException`, `UnauthorizedException`, `BadRequestException` o
   `ApiException`.

### Consecuencias

- Toda la lógica de auth HTTP vive en `auth_interceptor.dart`. Cambiar
  el esquema de auth (por ejemplo, mover a refresh tokens) requiere
  tocar solo ese archivo.
- Dependencia de un paquete de terceros, pero Dio es uno de los más
  usados de pub.dev y el riesgo de abandono es bajo.

---

## ADR-003: flutter_secure_storage para credenciales

**Fecha**: 2026-03-01

### Contexto

El paquete necesita persistir el JWT, el `userId`, el nombre y el email
del usuario entre sesiones para el "recordar sesión" sin exponer las
credenciales si el dispositivo está comprometido.

### Decisión

**flutter_secure_storage 9.x** envuelto en `SecureStorageService` con
una interfaz mínima (`saveToken`, `getToken`, `saveUserId`…).

### Alternativas descartadas

**SharedPreferences**
Persiste en XML (Android) o NSUserDefaults (iOS), accesibles sin cifrar
en dispositivos con root/jailbreak y susceptibles de incluirse en
backups sin proteger. No aceptable para JWT.

**Hive con cifrado opcional**
Una BD NoSQL local con cifrado. Sobredimensionado para 4-5 claves
simples y obliga a gestionar la clave de cifrado.

**En memoria sin persistencia**
Lo más seguro en disco (no toca disco), pero el usuario tendría que
logarse en cada arranque.

### Razones de la decisión

1. **Cifrado nativo**: Keychain (iOS) y EncryptedSharedPreferences
   (Android Keystore). Las claves están protegidas por material
   gestionado por el SO y no son accesibles ni con root sin la clave
   del dispositivo.
2. **API mínima**: read/write/delete sobre clave-valor, suficiente para
   los 4 campos persistidos.
3. **Estándar en Flutter**: paquete de referencia con mantenimiento
   activo.

### Consecuencias

- En emuladores Android sin Google Play Services y APIs muy antiguas
  el cifrado puede fallar; el mínimo soportado del proyecto (API 23+)
  funciona bien.
- Solo se persiste lo imprescindible: foto, rol, puntos y preferencias
  del usuario se traen siempre del backend.

---

## ADR-004: Modelos separados por audiencia (Usuario vs UsuarioAdmin)

**Fecha**: 2026-03-15

### Contexto

La app móvil y el panel admin comparten el endpoint de usuarios en
parte, pero el admin tiene acceso a información sensible (estado de
bloqueo, motivo, fecha) que la app cliente nunca debe ver.

### Decisión

Dos modelos separados en `lib/src/models/`:

- `Usuario` → modelo de cliente. Solo expone `id`, `nombre`, `email`,
  `foto`, `rol`, `puntosTotales`, `tema`, `idioma`.
- `UsuarioAdmin` → modelo extendido para el panel admin. Añade
  `fechaRegistro`, `activo`, `motivoBloqueo`, `fechaBloqueo`.

Cada uno lo construye su `fromJson` correspondiente y los repositorios
admin (`AdminRepository`) devuelven `UsuarioAdmin`, mientras los
repositorios de cliente (`UserRepository`) devuelven `Usuario`.

### Alternativas descartadas

**Modelo único con campos opcionales**
Un solo `Usuario` con `motivoBloqueo` y `fechaBloqueo` como nullable.
La API sigue sirviendo lo mismo, pero la app cliente potencialmente ve
campos que no le corresponden si un endpoint de admin le contesta. La
separación a nivel de tipo es más segura.

**Modelo plano + DTO admin separado**
Mantener `Usuario` y crear `UsuarioAdminDTO` solo dentro del repo
admin. Funciona pero acopla la decisión de exposición al consumidor en
vez de al paquete de datos.

### Razones de la decisión

1. **Seguridad por defecto**: la app cliente ni siquiera tiene
   visibilidad sobre los campos sensibles. Si el backend filtra info de
   admin a un endpoint de cliente, el `fromJson` del modelo `Usuario`
   ignora esos campos.
2. **Documentación implícita**: el nombre del tipo deja claro qué
   audiencia consume cada modelo.

### Consecuencias

- Si se añade un campo nuevo de cliente, hay que añadirlo a `Usuario` y
  posiblemente a `UsuarioAdmin`. Se acepta como duplicación intencional.
- El paquete exporta los dos modelos pero la app cliente nunca importa
  `UsuarioAdmin` a propósito.

---

## ADR-005: Versionado por tags git y consumo path/git según entorno

**Fecha**: 2026-03-01

### Contexto

DATA es consumido por APP y ADMIN. Hay que evitar que un cambio
breaking en DATA tumbe los clientes inmediatamente, y a la vez permitir
desarrollo local cómodo.

### Decisión

- Cada release de DATA crea un **tag git semver** (`v0.1.0`, `v0.2.0`,
  `v0.3.0`).
- En `pubspec.yaml` de APP/ADMIN se referencia DATA con `git: ref: vX.Y.Z`.
- En desarrollo local se sobreescribe con `pubspec_overrides.yaml`
  apuntando a `path: ../GrowTogetherDATA`. Ese archivo está en
  `.gitignore`.
- Los workflows de CI (`deploy.yml`) **borran** `pubspec_overrides.yaml`
  antes del `flutter pub get` para garantizar que el build de producción
  usa el tag git declarado.

### Alternativas descartadas

**Publicar a pub.dev**
El registro estándar de paquetes Dart. Excesivo para un paquete
privado de un proyecto académico y obliga a publicar cada bump.

**Solo `path:` en todos los entornos**
Funciona en local pero rompe en CI: GitHub Actions clona APP y no
tiene `../GrowTogetherDATA` al lado.

**Sin versionado, branch fija**
APP/ADMIN apuntan a `ref: main` de DATA. Cualquier merge a main de DATA
se aplica al siguiente build de los clientes, sin control. No
aceptable: un breaking change rompería los clientes sin aviso.

### Razones de la decisión

1. **Control explícito**: bumpear DATA a v0.4.0 no afecta a APP hasta
   que APP cambie su `ref: v0.3.0` por `ref: v0.4.0`.
2. **Reproducibilidad**: dado un commit de APP, sé exactamente qué
   versión de DATA está usando.
3. **Velocidad en local**: con `pubspec_overrides.yaml`, los cambios en
   DATA se ven sin necesidad de bumpear ni publicar.

### Consecuencias

- Releaseo manual de DATA: bumpear `version:` en `pubspec.yaml`,
  commitear, taggear (`git tag v0.X.0`), pushear tag.
- Si se necesita hotfix urgente en DATA, hay que hacer el ciclo
  completo (tag + bump APP + push APP + esperar CI).

---

## ADR-006: REST/JSON y mapeo en repositorios delgados

**Fecha**: 2026-03-01

### Contexto

La API es REST/JSON (decidido a nivel proyecto en
`GrowTogetherAPI/docs/DECISIONS.md`). Hay que decidir cómo se traducen
los DTOs JSON a modelos Dart y dónde vive la lógica.

### Decisión

**Repositorios delgados**: cada `*Repository` solo (1) hace la llamada
HTTP, (2) deserializa con `Modelo.fromJson(...)` y (3) normaliza
errores de Dio a `ApiException` y subclases. Toda la lógica de negocio
vive en el backend o en los `Provider` de cada cliente.

### Alternativas descartadas

**Repositorios con caché y lógica**
Un repositorio que cachee respuestas, valide reglas y combine endpoints.
Acopla DATA a las decisiones de cada cliente (¿qué cachear?, ¿durante
cuánto?), y dificulta los tests.

**Repositorios autogenerados con OpenAPI**
Generar el código a partir del schema. Funciona pero los nombres y la
forma de los métodos son los que decida la herramienta, no los que el
proyecto necesita.

### Razones de la decisión

1. **Reusable por dos clientes**: la app móvil cachea con
   `SharedPreferences`, el admin no cachea. Si el repo cacheara, no
   serviría para el admin tal cual.
2. **Test fácil**: cada repo se testea mockeando Dio. Sin lógica
   adicional no hay casos de borde extraños.
3. **Lectura directa del código**: la implementación de un endpoint
   cabe en 10 líneas. Cualquier desarrollador entiende qué hace sin
   profundizar.

### Consecuencias

- Lógica que se repetiría en APP y ADMIN (por ejemplo, cálculo de
  rachas) vive en el backend para no duplicarse.
- Los Providers de los clientes son los que deciden cuándo invalidar
  caché, reintentar o agrupar llamadas.

### Helper de errores unificado

El paquete expone una única función `handleDioError(e, mensaje)` en
`lib/src/api/dio_error_mapper.dart` que mapea:

- 401 → `UnauthorizedException`
- timeout / connectionError / receiveTimeout → `NetworkException`
- cualquier otro → `ApiException(mensaje, statusCode)`

Los repositorios la usan directamente cuando solo necesitan el flujo
estándar (`consejo`, `notificacion`, `habito`). Los repos con casuística
extra (`auth` con 401 = credenciales incorrectas, `user` con 404 = no
encontrado, `admin` con 400 con mensaje de body, `amistad` con 400 +
404, `desafio` con extracción de `message`) gestionan inline el caso
especial y delegan en `handleDioError` para el resto.

---

## ADR-007: Base64 para fotos de perfil en el modelo Usuario

**Fecha**: 2026-03-10
**Estado**: Aceptado (temporal — pendiente de revisión para despliegue cloud)

### Contexto

Los usuarios pueden personalizar su perfil con una foto. El modelo
`Usuario` tiene un campo `foto: String?` y el contrato con la API usa
ese campo para serializar la imagen.

### Decisión

**Base64 codificado como string** en el campo `foto`, persistido en la
BD del backend y transmitido en el JSON de respuesta del perfil. El
modelo `Usuario` lo guarda tal cual; cada cliente decodifica y muestra
con `Image.memory`.

### Alternativas descartadas

**S3 / Cloudinary / Azure Blob**
El estándar en producción. Modelo `Usuario` tendría `fotoUrl: String?`
y un cliente lo cargaría con `Image.network`. Mejor por CDN, compresión
y tamaño de BD, pero requiere infraestructura cloud configurada en
desarrollo. No es bloqueante para el TFG.

**Filesystem del servidor**
Almacenar archivos en disco del servidor y guardar la ruta en BD.
Funciona en single-instance pero rompe en multi-instance y complica
backups.

### Razones de la decisión

1. **Cero infraestructura**: todo viaja por la API JSON sin endpoints
   adicionales ni servicios cloud. El paquete DATA no necesita saber
   nada de S3.
2. **Tamaño controlado**: las apps cliente comprimen la foto a 150x150
   px con calidad 40% antes de enviar (decisión de los clientes, no
   de DATA), resultando en strings de ~3-5 KB.

### Consecuencias

- El modelo `Usuario` no expone helpers de decodificación; cada cliente
  decide cómo renderizar el Base64 (`Image.memory(base64Decode(foto))`).
- Esta decisión se revisará al desplegar en cloud para evitar el
  crecimiento de la columna `foto` en `usuarios`.

---

## ADR-008: Frecuencia de notificación derivada del hábito

**Fecha**: 2026-05-10

### Contexto

El modelo `Notificacion` originalmente tenía un campo `frecuencia`
(`'DIARIO'` / `'PERSONALIZADO'`) que duplicaba la información del
hábito asociado. El servicio que programa las alarmas locales en la
app móvil ya consultaba `habito.frecuencia` y `habito.diasSemana`,
nunca `notificacion.frecuencia`, por lo que el campo era redundante.

### Decisión

**El modelo `Notificacion` no tiene campo `frecuencia`**. La
periodicidad efectiva con la que la noti se dispara la decide el
cliente derivándola del hábito asociado:

- Hábito `DIARIO` → una alarma local diaria a la hora indicada.
- Hábito `PERSONALIZADO` → tantas alarmas semanales como días en
  `habito.diasSemana`, todas a la misma hora.

### Alternativas descartadas

**Mantener el campo y duplicar la información**
Coste: un campo más en el modelo y dos sitios (hábito y noti) donde
puede divergir la frecuencia. Si difieren, ¿cuál gana? No hay caso de
uso que justifique permitir la divergencia.

**Permitir que la noti tenga sus propios días, distinta del hábito**
Más flexible, pero exige añadir `diasSemana` al modelo `Notificacion`
y al DTO de la API, además del esfuerzo de UI para gestionarlo. No es
necesario para el TFG.

### Razones de la decisión

1. **Una única fuente de verdad**: la frecuencia vive en el hábito.
2. **Menos campos en el modelo**: menos código que mantener y testear.
3. **Coherente con el comportamiento ya implementado** del servicio
   `LocalNotificationsService`.

### Consecuencias

- Backend y cliente sincronizados desde `DATA v0.5.0` y `API`
  desplegada el 2026-05-10:
  - La columna `frecuencia` se eliminó de la tabla `notificaciones`
    en RDS con `ALTER TABLE notificaciones DROP COLUMN frecuencia`.
  - El DTO `NotificacionDto` y la entidad `Notificacion` de la API
    ya no exponen el campo.
  - El repositorio cliente (`NotificacionRepository`) ya no envía
    `'DIARIO'` hardcoded en `crear` y `actualizar`.
