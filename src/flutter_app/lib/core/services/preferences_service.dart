import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyPairingCode = 'pairing_code';
  static const _keyDeviceName = 'device_name';
  static const _keyDefaultCwd = 'default_cwd';
  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  String? getPairingCode() => _prefs.getString(_keyPairingCode);
  Future<void> setPairingCode(String code) =>
      _prefs.setString(_keyPairingCode, code);
  Future<void> clearPairingCode() => _prefs.remove(_keyPairingCode);

  String? getDeviceName() => _prefs.getString(_keyDeviceName);
  Future<void> setDeviceName(String name) =>
      _prefs.setString(_keyDeviceName, name);
  Future<void> clearDeviceName() => _prefs.remove(_keyDeviceName);

  String? getDefaultCwd() => _prefs.getString(_keyDefaultCwd);
  Future<void> setDefaultCwd(String cwd) =>
      _prefs.setString(_keyDefaultCwd, cwd);

  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  Future<void> clearAll() async {
    await clearPairingCode();
    await clearDeviceName();
  }
}
