<p align="center">
  <img src="https://via.placeholder.com/160x160/0d1117/58a6ff?text=RM" alt="Runmote logo" width="160" />
  <!-- [LOGO HERE] -->
</p>

<p align="center">
  <a href="https://github.com/Raza-learner/Runmote/actions"><img src="https://img.shields.io/github/actions/workflow/status/Raza-learner/Runmote/ci-python.yml?branch=main&label=build" alt="Build status" /></a>
  <a href="https://github.com/Raza-learner/Runmote/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License MIT" /></a>
  <a href="#"><img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter" /></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.13+-green?logo=python" alt="Python" /></a>
  <a href="#"><img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey" alt="Platform" /></a>
  <a href="https://github.com/Raza-learner/Runmote/stargazers"><img src="https://img.shields.io/github/stars/Raza-learner/Runmote?style=social" alt="GitHub stars" /></a>
</p>

<br />

<h3 align="center">Run any AI agent on your PC from your phone.</h3>

<p align="center">
Runmote connects your phone to the AI coding agents running on your computer —
no SSH, no VPN, no port forwarding. Just a 6-digit code and you're in.
Fire up <code>opencode</code>, <code>claude code</code>, <code>codex</code>, or any ACP agent
from anywhere — commute, coffee shop, couch. Your sessions, your tools, your machine.
</p>

<br />

<p align="center">
  <img src="https://via.placeholder.com/800x420/0d1117/58a6ff?text=Runmote+Demo" alt="Runmote demo" width="800" />
  <!-- [DEMO GIF HERE] -->
</p>

<br />

---

## Features

- **Zero config** — installs in one command, detects your agents automatically
- **Pairing code** — type a 6-digit code in the app, done
- **Persistent sessions** — resume any session from where you left off
- **Real-time streaming** — see the agent think, tool calls, and diffs live on your phone
- **Works everywhere** — home WiFi, office network, 4G, airplane hotspot
- **Cross-platform daemon** — Linux, macOS, Windows
- **Self-hostable relay** — the relay server is open source, run your own

<br />

## How it works

```
  ┌──────────────────────┐          ┌──────────────────┐          ┌─────────────────────┐
  │  Install daemon      │   ──►    │  Open Runmote    │   ──►    │  Start coding       │
  │  on your PC          │          │  app on phone    │          │  from anywhere       │
  │                      │          │                  │          │                      │
  │  curl runmote.dev/   │          │  Enter pairing   │          │  Full chat + toolkit │
  │  install.sh | bash   │          │  code from       │          │  across any network  │
  │                      │          │  terminal        │          │                      │
  └──────────────────────┘          └──────────────────┘          └─────────────────────┘
```

<br />

## Supported agents

Runmote works with any agent that speaks the [Agent Client Protocol](https://agentclientprotocol.com) (JSON-RPC 2.0 over stdin/stdout).

| Agent | Status | Link |
|-------|--------|------|
| OpenCode | ✅ Tested | [opencode.ai](https://opencode.ai) |
| Claude Code | ✅ Tested | [claude.ai/code](https://claude.ai/code) |
| Codex | ✅ Tested | [openai.com](https://openai.com) |
| Gemini CLI | ✅ Tested | [gemini.google.com](https://gemini.google.com) |
| Cursor | ✅ Tested | [cursor.sh](https://cursor.sh) |
| Copilot | ✅ Tested | [github.com/copilot](https://github.com/copilot) |

<br />

## Quick install

<details open>
<summary><b>Linux / macOS</b></summary>

```bash
curl -fsSL https://runmote.dev/install.sh | bash
```

</details>

<details>
<summary><b>Windows</b></summary>

```powershell
powershell -c "irm https://runmote.dev/install.ps1 | iex"
```

</details>

After install:

```bash
runmote              # start daemon → shows pairing code
runmote start        # restart daemon
runmote stop         # stop daemon
runmote status       # check if daemon is running
runmote code         # show pairing code
runmote --uninstall  # remove everything
```

<br />

## Architecture

```
  ┌─────────────┐     WebSocket (WSS)     ┌──────────────┐     WebSocket (WSS)     ┌─────────────────┐
  │ Runmote App │ ◄─────────────────────► │ Relay Server │ ◄─────────────────────► │ Daemon (your PC)│
  │  (Flutter)  │                         │  (FastAPI)   │                         │    (Python)     │
  └─────────────┘                         └──────────────┘                         └────────┬────────┘
                                                                                             │
                                                                                     stdin / stdout
                                                                                    (JSON-RPC 2.0)
                                                                                             │
                                                                                     ┌───────▼────────┐
                                                                                     │   ACP Agent    │
                                                                                     │  opencode /    │
                                                                                     │  claude / codex│
                                                                                     └────────────────┘
```

The Flutter app and daemon never talk directly. The relay sits in the middle, routing every message over secure WebSocket. The daemon pipes JSON-RPC to the agent process on your machine — exactly like a local terminal.

<br />

## Why Runmote?

| | SSH tunnel | VPN | Runmote |
|---|---|---|---|
| Setup time | 30+ min | 1 hour | 2 minutes |
| Port forwarding | Required | Required | None |
| Works on 4G | Sometimes | Yes | Yes |
| Mobile app | No | No | Yes |
| Session history | No | No | Yes |
| Self-hostable | — | — | Yes |
| Open source | — | — | MIT |

<br />

## Project structure

<details>
<summary>Expand tree</summary>

```
runmote/
├── src/
│   ├── daemon/              # Python daemon (runs on your PC)
│   │   ├── main.py          # core bridge — relay ↔ agent
│   │   └── config.py        # agent auto-detection
│   ├── relay/               # FastAPI relay server
│   │   ├── main.py          # server entry point
│   │   ├── pairing.py       # 6-digit pairing codes
│   │   ├── database.py      # SQLite via Drift
│   │   ├── session_store.py # session persistence
│   │   ├── state.py         # WebSocket connection state
│   │   ├── discovery.py     # LAN discovery (mDNS)
│   │   └── handlers/
│   │       ├── app.py       # mobile app WebSocket handler
│   │       └── daemon.py    # daemon WebSocket handler
│   ├── common/              # shared utilities
│   │   └── logger.py        # structured logging
│   └── flutter_app/         # Mobile app
│       └── lib/
│           ├── main.dart
│           ├── app.dart
│           ├── features/
│           │   ├── pair/        # pairing screen
│           │   ├── agents/      # agent list
│           │   ├── sessions/    # session list
│           │   ├── chat/        # chat UI + streaming
│           │   └── settings/    # MCP servers, preferences
│           ├── core/
│           │   ├── providers/   # Riverpod state
│           │   ├── models/      # Freezed data models
│           │   ├── database/    # Drift (local SQLite)
│           │   ├── router/      # GoRouter config
│           │   ├── services/    # prefs, env
│           │   └── theme/       # app colors, spacing
│           └── shared/
│               └── widgets/     # diff viewer, terminal,
│                                # status badges, animated bg
├── scripts/
│   ├── install.sh              # Linux/macOS one-liner
│   ├── install.ps1             # Windows one-liner
│   ├── runmote                 # CLI launcher
│   ├── setup-autostart.sh      # systemd / launchd config
│   ├── setup-autostart.ps1     # Windows task scheduler
│   ├── set-version.sh          # version bumper
│   └── lib/                    # shared installer helpers
├── tests/                      # Python test suite
├── Dockerfile.relay            # relay Docker image
├── docker-compose.yml
├── pyproject.toml
└── VERSION
```

</details>

<br />

## FAQ

<details>
<summary><b>Does my PC need to be on?</b></summary>
Yes — the daemon runs on your machine and must be online for you to connect.
</details>

<details>
<summary><b>Is it secure?</b></summary>
All traffic is encrypted over WSS (WebSocket over TLS). Session data lives on your machine,
not on the relay. You can also self-host the relay for complete control.
</details>

<details>
<summary><b>Which agents work with Runmote?</b></summary>
Any agent implementing the ACP specification — OpenCode, Claude Code, Codex, Gemini CLI,
Cursor, Copilot, and others.
</details>

<details>
<summary><b>Does it work on iOS and Android?</b></summary>
Yes — the Runmote app is built with Flutter and runs on both platforms.
APK is available in releases; iOS TestFlight coming soon.
</details>

<details>
<summary><b>Can I host my own relay server?</b></summary>
Yes. The relay is fully open source. Run it with Docker or deploy to Render in minutes.
See the <code>Dockerfile.relay</code> and <code>docker-compose.yml</code>.
</details>

<br />

## Contributing

Pull requests are welcome. For major changes, open an issue first to discuss.

```bash
git clone https://github.com/Raza-learner/Runmote.git
cd Runmote
uv sync                     # install Python deps
cd src/flutter_app && flutter pub get   # install Flutter deps
```

<br />

## Author

<p align="left">
Built by <b>Raza</b> — a CS student who learned Flutter and Python simultaneously
while building something real. If Runmote saved you time, consider buying me a coffee.
</p>

<p align="left">
  <a href="https://www.buymeacoffee.com/raza"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee" /></a>
  <a href="https://github.com/sponsors/Raza-learner"><img src="https://img.shields.io/badge/sponsor-30363D?logo=github-sponsors&logoColor=#EA4AAA" alt="GitHub Sponsor" /></a>
</p>

<br />

## License

MIT © [Raza](https://github.com/Raza-learner)

<br />

<p align="center">
  <a href="https://star-history.com/#Raza-learner/Runmote&Date">
    <img src="https://api.star-history.com/svg?repos=Raza-learner/Runmote&type=Date" alt="Star History Chart" width="600" />
  </a>
</p>

<br />

<p align="center">Made with ❤️ by a student developer</p>
