import 'package:flutter_dotenv/flutter_dotenv.dart';

const _fallbackRelayUrl = 'wss://runmote-relay-u2zi.onrender.com';

String get defaultRelayUrl => dotenv.env['ACP_RELAY_URL'] ?? _fallbackRelayUrl;

/// True if [url] points to Runmote's managed cloud relay. In that case the
/// app shows a friendly name instead of the raw wss link.
bool isCloudRelay(String url) {
  final u = url.trim().toLowerCase();
  return u.contains('runmote-relay-u2zi.onrender.com') ||
      u == _fallbackRelayUrl.toLowerCase();
}

/// Display string for a relay URL. Cloud -> "Runmote Relay", custom -> raw url.
String relayDisplayName(String url) =>
    isCloudRelay(url) ? 'Runmote Relay' : url;

/// Short subtitle for the relay.
String relayDisplaySubtitle(String url) =>
    isCloudRelay(url) ? 'Cloud • Secure' : 'Custom relay';
