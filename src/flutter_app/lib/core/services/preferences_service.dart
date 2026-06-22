import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyRelayUrl = 'relay_url';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLastCwd = 'last_cwd';
  static const _keyTelemetryEnabled = 'telemetry_enabled';
  static const _keyConsentDismissed = 'consent_dismissed';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  String get relayUrl => _prefs.getString(_keyRelayUrl) ?? 'ws://localhost:8000/app';
  set relayUrl(String value) => _prefs.setString(_keyRelayUrl, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  set themeMode(String value) => _prefs.setString(_keyThemeMode, value);

  String? get lastCwd => _prefs.getString(_keyLastCwd);
  set lastCwd(String? value) {
    if (value != null) {
      _prefs.setString(_keyLastCwd, value);
    } else {
      _prefs.remove(_keyLastCwd);
    }
  }

  bool get telemetryEnabled =>
      _prefs.getBool(_keyTelemetryEnabled) ?? false;
  set telemetryEnabled(bool value) =>
      _prefs.setBool(_keyTelemetryEnabled, value);

  bool get consentDismissed =>
      _prefs.getBool(_keyConsentDismissed) ?? false;
  set consentDismissed(bool value) =>
      _prefs.setBool(_keyConsentDismissed, value);
}
