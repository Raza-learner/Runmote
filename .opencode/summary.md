# ACP — Project Summary

## Work State

**Phase**: Auto-reconnect & cloud-relay default — code complete, pending rebuild/deploy.

### Completed

1. **Relay: token persistence across daemon disconnects** (`src/relay/state.py`)
   - `known_tokens: dict[str, str]` maps token → daemon_id, survives disconnects.
   - `get_daemon_id_by_token()` checks both active (`daemons`) and offline (`known_tokens`) daemons.

2. **Relay: save token on daemon identify** (`src/relay/handlers/daemon.py`)
   - On daemon identify, token is saved to `known_tokens`.

3. **Relay: graceful offline-daemon response** (`src/relay/handlers/app.py`)
   - `auth/token` uses `get_daemon_id_by_token()`.
   - Token valid but daemon offline → `{authenticated: true, daemonConnected: false}` instead of "invalid token".

4. **App: no mDNS blocking, cloud-relay default** (`src/flutter_app/lib/features/pair/view/pair_screen.dart`)
   - Pairing options (QR + manual) shown immediately — no wait for mDNS.
   - Default relay URL: `wss://relay.runmote.dev`.
   - Auto-connect falls back to `_defaultRelayUrl` if saved URL fails.
   - Removed dead code (`_buildSearching`, `_buildError`, `_StatusChip`, `_PulsingDots`).
   - Debug logging (`[RUNMOTE]` prefix) added to `_autoConnectWithToken`.

5. **App: URL sanitization & diagnostics** (`src/flutter_app/lib/core/providers/connection_provider.dart`)
   - `_sanitizeRelayUrl()` strips trailing slashes, converts `http://`→`ws://`, `https://`→`wss://`.
   - Default URL: `wss://relay.runmote.dev`.
   - On successful `connectWithToken`, sanitized URL saved back to SharedPreferences.
   - Debug logging (`[RUNMOTE]`) before connecting — shows resolved WS URI.

### Active

- Rebuild Flutter app (`flutter build`) and reinstall on device to get new code + clear old SharedPreferences.
- Verify `relay.runmote.dev` CNAME is set to DNS-only (grey cloud) in Cloudflare.

### Next Move

1. Rebuild and deploy the Flutter app.
2. Verify `relay.runmote.dev` CNAME is grey-cloud (DNS only) in Cloudflare.
3. Verify cron trigger `*/13 * * * *` is added in Cloudflare Worker Triggers.
4. Test end-to-end: pair, disconnect daemon, reconnect app, verify auto-reconnect works.
