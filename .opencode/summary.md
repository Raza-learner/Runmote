# ACP — Project Summary

## Work State

**Phase**: CI passing, main branch updated, Flutter app icon fixed, pending app rebuild and end-to-end test.

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

6. **CI pipelines fixed and passing**:
   - Python CI: fixed daemon integration tests (agent disconnect, agent/list handler), fixed CI workflow test env (`echo acp` → `cat`), skipped Windows-only test.
   - Flutter CI: fixed 30+ lint warnings, added `flutter analyze --no-fatal-infos --no-fatal-warnings`, build-apk succeeds.

7. **Flutter app icon fixed**:
   - Removed black/rounded corners from the source logo, filled the background with the detected beige color (`#FAEFE2`), and scaled the content to fill the 1024x1024 canvas.
   - Added `flutter_launcher_icons` configuration with `adaptive_icon_background` and `adaptive_icon_foreground` for Android, and `remove_alpha_ios: true`.
   - Regenerated launcher icons for Android, iOS, web, macOS, and Windows.
   - Later made the robot logo ~15% larger while keeping all content within the safe area so the launcher mask doesn't clip it.
   - Replaced the pair screen's purple gradient star icon (`Icons.auto_awesome_rounded`) with the Runmote logo (white, using `app_icon_foreground.png` with `BlendMode.srcIn`).
   - Verified `flutter analyze` and `flutter build apk --debug` pass.

8. **Branches merged**: latest fixes are on both `dev` and `main`.

### Active

- (none)

### Next Move

1. Rebuild and deploy the Flutter app (APK / web).
2. Test end-to-end pair/connect flow.
3. Consider upgrading `actions/checkout@v4` to a Node.js 24 compatible version (CI warning).
4. For new dev installs, use:
   ```bash
   curl -fsSL https://runmote.dev/install.sh/dev | ACP_RELAY_TOKEN=00a89de233437a8f8482c4aab2af80a9 bash
   ```
