# ACP — Project Summary

## Work State

**Phase**: Dev branch installer + relay defaults fixed; daemon manually running; pending push/merge and app rebuild.

### Completed

1. **Root cause identified**: installed daemon was from `main` even when running `/install.sh/dev`, because `scripts/install.sh` defaulted to `BRANCH="${ACP_RELAY_BRANCH:-main}"`. This installed old code still using the broken `relay.runmote.dev` URL.

2. **Fixed running daemon manually**:
   - Updated `/home/raza/.local/share/runmote/src/daemon/config.py` to use relay host `runmote-relay-u2zi.onrender.com`.
   - Added `ACP_DAEMON_TOKEN=67bcb1b81fd2ae0e6c3b93ddf6a5e445` to `/home/raza/.config/systemd/user/runmote.service`.
   - Restarted daemon; it connected and shows pairing code `TRV5-TRBU`.
   - Relay health shows `{"status":"ok","daemons_connected":1}`.

3. **Fixed dev branch installer**:
   - `scripts/install.sh`: default branch changed from `main` to `dev` so `/install.sh/dev` installs dev code.
   - `scripts/lib/wizard.sh`: `wizard_cloud_relay()` now requires `ACP_RELAY_TOKEN` in non-interactive mode and defaults to cloud relay.

4. **Updated dev branch defaults to dev relay**:
   - `src/daemon/config.py`: default host `runmote-relay.onrender.com`.
   - `src/flutter_app/lib/core/providers/connection_provider.dart`: default URL `wss://runmote-relay.onrender.com`.
   - `src/flutter_app/lib/features/pair/view/pair_screen.dart`: default URL `wss://runmote-relay.onrender.com`.
   - `worker.js`: info text updated.
   - `README.md`: updated.

5. **Tokens identified**:
   - Main relay (`runmote-relay-u2zi.onrender.com`): `67bcb1b81fd2ae0e6c3b93ddf6a5e445`.
   - Dev relay (`runmote-relay.onrender.com`): `00a89de233437a8f8482c4aab2af80a9`.

### Active

- Push dev branch so the Worker serves the updated `install.sh/dev`.
- Update main branch so `curl https://runmote.dev/install.sh | bash` works (currently main still has `relay.runmote.dev` default). Requires merging dev into main or manually updating main branch files.

### Next Move

1. Push the dev branch to deploy the updated `install.sh/dev`.
2. Merge dev into main (or manually update main branch files) so the production installer points to the working relay.
3. Rebuild and deploy the Flutter app; test end-to-end pair/connect flow.
4. For new dev installs, use:
   ```bash
   curl -fsSL https://runmote.dev/install.sh/dev | ACP_RELAY_TOKEN=00a89de233437a8f8482c4aab2af80a9 bash
   ```
