<div align="center">
  <br />
  <img src="https://via.placeholder.com/120x120/0d1117/58a6ff?text=RM" alt="Runmote" width="120" />
  <!-- [LOGO HERE] -->

  <h1>Runmote</h1>

  <h3>Your PC's AI agents. In your pocket. Anywhere.</h3>

  <p>
    Start an <code>opencode</code> session from the bus. Resume <code>claude code</code> from bed.<br />
    Fix a bug with <code>codex</code> while waiting for coffee.
    <br /><br />
    <b>No SSH. No VPN. No port forwarding.</b>
  </p>

  <p>
    <a href="https://github.com/Raza-learner/Runmote/actions"><img src="https://img.shields.io/github/actions/workflow/status/Raza-learner/Runmote/ci-python.yml?branch=main&label=build" alt="Build" /></a>
    <a href="https://github.com/Raza-learner/Runmote/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Python-3.13+-green?logo=python" alt="Python" /></a>
    <a href="#"><img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey" alt="iOS Android" /></a>
    <a href="https://github.com/Raza-learner/Runmote/stargazers"><img src="https://img.shields.io/github/stars/Raza-learner/Runmote?style=social" alt="Stars" /></a>
  </p>

  <br />
  <img src="https://via.placeholder.com/800x420/0d1117/58a6ff?text=Runmote+Demo" alt="Demo" width="800" />
  <!-- [DEMO GIF HERE] -->
  <br />
  <br />
</div>

---

## Install

<table>
<tr>
<td width="50%">

### Linux / macOS

```bash
curl -fsSL https://runmote.dev/install.sh | bash
```

</td>
<td width="50%">

### Windows

```powershell
powershell -c "irm https://runmote.dev/install.ps1 | iex"
```

</td>
</tr>
</table>

That's it. Two minutes. After install:

```bash
runmote start          # daemon starts -> shows pairing code in terminal
runmote code           # re-display pairing code anytime
runmote status         # check if daemon is running
runmote stop           # stop the daemon
runmote --uninstall    # clean removal
```

---

## Why Runmote?

You *could* SSH tunnel into your PC. If you like typing firewall rules at 11pm.

| | SSH | Runmote |
|---|---|---|
| **Setup time** | 30 minutes of iptables hell | One curl command |
| **Port forwarding** | Yes, on every network | Never |
| **Works on 4G** | Only if you port-forwarded | Yes -- it's just the internet |
| **Mobile app** | Termius + tmux + prayer | Native Flutter app |
| **Session persistence** | tmux resurrection scripts | Built-in, automatic |
| **Keep your sessions** | Hope screen didn't die | Resumes from last message |

---

## Features

- **One command install** -- auto-detects your agents, no config files
- **6-digit pairing** -- open app, type code, connected
- **Persistent sessions** -- switch apps, phone dies, you're right where you left off
- **Streaming responses** -- watch the agent think, run tools, apply diffs live
- **Works on any network** -- home, office, 4G, coffee shop WiFi
- **Cross-platform** -- daemon runs on Linux, macOS, Windows
- **Self-hostable relay** -- everything is open source, run your own server

---

## How it works

```
  ┌─────────────────────────┐               ┌─────────────────────────┐               ┌──────────────────────────┐
  │    1. Install daemon    │               │  2. Open Runmote app    │               │  3. Code from anywhere   │
  │        on your PC       │      -->      │      on your phone      │      -->      │                           │
  │                         │               │                         │               │                           │
  │  curl runmote.dev/      │               │  Enter 6-digit code     │               │  Full chat + toolkit     │
  │  install.sh | bash      │               │  from terminal          │               │  any network, no config  │
  └─────────────────────────┘               └─────────────────────────┘               └──────────────────────────┘
```

---

## Supported agents

| Agent | Status | Get it |
|-------|--------|--------|
| **OpenCode** | Tested | [opencode.ai](https://opencode.ai) |
| **Claude Code** | Tested | [claude.ai/code](https://claude.ai/code) |
| **Codex** | Tested | [openai.com](https://openai.com) |
| **Gemini CLI** | Tested | [gemini.google.com](https://gemini.google.com) |
| **Cursor** | Tested | [cursor.sh](https://cursor.sh) |
| **Copilot** | Tested | [github.com/copilot](https://github.com/copilot) |

Any agent that speaks [ACP](https://agentclientprotocol.com) works. Got one not listed? Open an issue.

---

## Architecture

```
  ┌─────────────┐     WebSocket (WSS)     ┌──────────────┐     WebSocket (WSS)     ┌─────────────────┐
  │ Runmote App │ <---------------------> │ Relay Server │ <---------------------> │ Daemon (your PC)│
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

No hacks. Phone talks to relay, relay talks to daemon, daemon pipes to agent. All WSS encrypted.

---

## FAQ

<details>
<summary><b>Does my PC need to stay on?</b></summary>

Yes -- the daemon runs as a background process on your machine. It won't use resources when idle.

</details>

<details>
<summary><b>Is this secure?</b></summary>

Every connection is encrypted with WSS (WebSocket over TLS). Session data lives on your machine, not the relay. Self-host the relay if you want full control -- it's a single Docker container.

</details>

<details>
<summary><b>How does pairing work -- can anyone connect?</b></summary>

The daemon generates a fresh 6-digit code each time it starts. Only someone who can see your terminal (or the log file) can get that code. Codes rotate on daemon restart.

</details>

<details>
<summary><b>What agents are supported?</b></summary>

Any agent that implements the [Agent Client Protocol](https://agentclientprotocol.com) -- OpenCode, Claude Code, Codex, Gemini CLI, Cursor, Copilot, and others. The daemon auto-detects what's installed.

</details>

<details>
<summary><b>Does this work on iPhone AND Android?</b></summary>

Yes. The app is built with Flutter and compiled natively for both platforms. APK available in releases. iOS TestFlight coming soon.

</details>

<details>
<summary><b>Can I run my own relay instead of the public one?</b></summary>

Absolutely. The relay is 100% open source. Build it with Docker:

```bash
docker compose up -d
```

Then set `ACP_RELAY_URL` in your daemon environment to point to your server.

</details>

---

## Project structure

<details>
<summary><b>Expand tree</b></summary>

```
runmote/
├── src/
│   ├── daemon/              # Python daemon (runs on your PC)
│   │   ├── main.py          # core bridge -- relay <-> agent
│   │   └── config.py        # agent auto-detection
│   ├── relay/               # FastAPI relay server
│   │   ├── main.py          # entry point
│   │   ├── pairing.py       # 6-digit codes
│   │   ├── database.py      # SQLite
│   │   ├── session_store.py # persistence
│   │   ├── state.py         # WebSocket state
│   │   ├── discovery.py     # LAN discovery (mDNS)
│   │   └── handlers/
│   │       ├── app.py       # mobile app handler
│   │       └── daemon.py    # daemon handler
│   ├── common/              # shared utils
│   │   └── logger.py
│   └── flutter_app/         # Mobile app
│       └── lib/
│           ├── features/
│           │   ├── pair/        # pairing screen
│           │   ├── agents/      # agent list
│           │   ├── sessions/    # session list
│           │   ├── chat/        # chat + streaming + diffs
│           │   └── settings/    # MCP servers, prefs
│           ├── core/
│           │   ├── providers/   # Riverpod state
│           │   ├── models/      # Freezed models
│           │   ├── database/    # Drift (local SQLite)
│           │   ├── router/      # GoRouter
│           │   ├── services/    # prefs, env
│           │   └── theme/       # colors, spacing
│           └── shared/
│               └── widgets/     # diff viewer, terminal,
│                                # status badges, animated bg
├── scripts/
│   ├── install.sh              # Linux/macOS one-liner
│   ├── install.ps1             # Windows one-liner
│   ├── runmote                 # CLI launcher
│   ├── setup-autostart.sh      # systemd / launchd
│   ├── setup-autostart.ps1     # Windows autostart
│   ├── set-version.sh          # version bumper
│   └── lib/                    # shared helpers
├── tests/                      # Python test suite
├── Dockerfile.relay            # relay Docker image
├── docker-compose.yml
├── pyproject.toml
└── VERSION
```

</details>

---

## Contributing

Pull requests are welcome. For major changes, open an issue first to discuss.

```bash
git clone https://github.com/Raza-learner/Runmote.git
cd Runmote
uv sync                          # install Python deps
cd src/flutter_app && flutter pub get  # install Flutter deps
```

---

## Author

<p align="left">
Built by <b>Raza</b>, an independent developer who shipped Runmote from scratch
across three platforms — Python daemon, Flutter mobile app, and a real-time relay server.
If this project saved you time or made your workflow better, consider supporting it.
</p>

<p align="left">
  <a href="https://buymeacoffee.com/raza"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee" /></a>
  <a href="https://github.com/sponsors/Raza-learner"><img src="https://img.shields.io/badge/sponsor-30363D?logo=github-sponsors&logoColor=#EA4AAA" alt="GitHub Sponsor" /></a>
</p>

---

## License

MIT © [Raza](https://github.com/Raza-learner)

<br />

<p align="center">
  <a href="https://star-history.com/#Raza-learner/Runmote&Date">
    <img src="https://api.star-history.com/svg?repos=Raza-learner/Runmote&type=Date" alt="Star History Chart" width="600" />
  </a>
</p>

<br />

<p align="center">Made with love</p>
