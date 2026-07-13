import 'package:flutter_dotenv/flutter_dotenv.dart';

const _fallbackRelayUrl = 'wss://runmote-relay.onrender.com';

String get defaultRelayUrl => dotenv.env['ACP_RELAY_URL'] ?? _fallbackRelayUrl;
