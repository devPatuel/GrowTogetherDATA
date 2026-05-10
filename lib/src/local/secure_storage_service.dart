import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento cifrado de credenciales y datos mínimos del usuario logueado.
///
/// Usa Keychain en iOS y EncryptedSharedPreferences (Android Keystore) en
/// Android: las claves están cifradas con material gestionado por el SO y no
/// son accesibles ni con root sin la clave del dispositivo.
///
/// Solo se persiste lo imprescindible para reabrir sesión y montar el perfil
/// inicial sin pegarle a la API: token JWT, id, nombre y email. El resto
/// (foto, rol, puntos, preferencias) se carga del backend tras verificar
/// sesión.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  // Token
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<bool> hasToken() async => (await getToken()) != null;

  // Identidad
  Future<void> saveUserId(int id) => _storage.write(key: _userIdKey, value: id.toString());
  Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> saveUserName(String name) => _storage.write(key: _userNameKey, value: name);
  Future<String?> getUserName() => _storage.read(key: _userNameKey);

  Future<void> saveUserEmail(String email) => _storage.write(key: _userEmailKey, value: email);
  Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);

  /// Borra todas las claves: usado al cerrar sesión o al recibir un 401 que
  /// invalida el token vigente.
  Future<void> deleteAll() => _storage.deleteAll();
}
