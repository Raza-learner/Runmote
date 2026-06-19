# ACP Remote — Run AI Agents from Your Phone

Control any ACP-compatible AI agent installed on your PC from your phone, over the internet.

## The Problem

ACP (Agent Client Protocol) requires the client and host to run on the same machine. This project removes that limitation by adding a relay server and a daemon so you can use your phone as a remote client.

## Architecture

```
Flutter App (phone)
      ↕  WebSocket
Relay Server (VPS)        ← FastAPI, always online
      ↕  WebSocket
Daemon (your PC)          ← Python, runs in background
      ↕  stdin/stdout
ACP Agent (opencode, etc) ← runs locally on your PC
```

## Project Structure

```
ACP/
├── src/
│   ├── daemon/
│   │   ├── main.py        # connects to relay, bridges to ACP agent
│   │   └── config.py      # relay URL, agent command, daemon ID
│   │
│   └── relay/
│       ├── main.py        # FastAPI relay server
│       └── config.py      # host, port settings
│
└── tests/
    └── test_client.py     # simulates the Flutter app for testing
```

## Components

### Daemon (`src/daemon/`)
A Python background process that runs on your PC. It:
- Connects **outbound** to the relay server via WebSocket (no open ports needed)
- Spawns the ACP agent as a subprocess (`opencode acp`)
- Bridges messages between the relay and the agent's stdin/stdout

### Relay Server (`src/relay/`)
A FastAPI server hosted on a VPS. It:
- Accepts WebSocket connections from both the daemon (`/daemon`) and the app (`/app`)
- Routes messages between them using an async queue
- Acts as the middleman so phone and PC never connect directly

### Flutter App
Coming soon. Will replace `test_client.py` as the mobile UI.

## Prerequisites

- Python 3.11+
- [uv](https://github.com/astral-sh/uv) (recommended) or pip
- [opencode](https://opencode.ai) installed and authenticated on your PC
- A VPS for hosting the relay (for local dev, `localhost` works fine)

## Installation

```bash
# clone the repo
git clone https://github.com/yourname/acp-remote
cd acp-remote

# install dependencies
uv sync
```

## Running Locally (Development)

You need three terminals:

**Terminal 1 — Relay server**
```bash
cd src/relay
uvicorn main:app --port 8000
```

**Terminal 2 — Daemon**
```bash
cd src/daemon
uv run main.py
```

**Terminal 3 — Test client (simulates phone)**
```bash
cd tests
uv run test_client.py
```

You should see:
```
Relay:  Daemon connected!
Relay:  Client connected!
Daemon: relay → agent: {"jsonrpc":"2.0",...}
Daemon: agent → relay: {"jsonrpc":"2.0",...}
Client: response: {"jsonrpc":"2.0","result":{...}}
```

## Configuration

### `src/daemon/config.py`
```python
RELAY_URL = "ws://localhost:8000/daemon"  # change to your VPS URL in production
AGENT_COMMAND = ["opencode", "acp"]       # swap for any ACP-compatible agent
DAEMON_ID = "my-pc"                       # identifies your machine
```

### `src/relay/config.py`
```python
HOST = "localhost"   # change to 0.0.0.0 in production
PORT = 8000
```

## How It Works

1. Daemon starts and connects outbound to the relay at `/daemon`
2. Flutter app (or test client) connects to the relay at `/app`
3. App sends a JSON-RPC message → relay forwards it to daemon
4. Daemon writes it to the ACP agent's stdin
5. Agent responds on stdout → daemon reads it → sends to relay
6. Relay puts it in a queue → app receives the response

The daemon always connects outbound, so **no port forwarding or firewall rules** are needed on your PC.

## ACP Message Format

ACP uses JSON-RPC 2.0 over stdin/stdout. Example:

```json
// initialize
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":1}}

// response
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":1,"agentInfo":{"name":"OpenCode","version":"1.17.8"}}}
```

## Roadmap

- [x] Daemon — WebSocket + subprocess bridge
- [x] Relay server — FastAPI with async queue
- [ ] Auth — API key or JWT between daemon and relay
- [ ] Flutter app — mobile chat UI
- [ ] Deploy relay to VPS
- [ ] Auto-reconnect on daemon disconnect
- [ ] Support multiple simultaneous agents
- [ ] Support multiple connected phones

## Tech Stack

| Component | Technology |
|-----------|------------|
| Daemon | Python, asyncio, websockets |
| Relay | Python, FastAPI, uvicorn |
| Mobile app | Flutter (Dart) |
| Protocol | ACP (JSON-RPC 2.0 over stdin/stdout) |
