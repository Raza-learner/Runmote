# ACP Remote

## Goal

Build a secure remote AI development platform.

Users install a lightweight daemon on their PC.

The daemon automatically discovers local ACP-compatible agents such as:

* Claude Code
* OpenCode
* Codex
* Gemini CLI
* Custom ACP agents

The daemon connects to a Relay running on a VPS.

A Flutter mobile application connects only to the Relay.

The phone can:

* View all connected computers
* View available AI agents
* View agent sessions
* Resume sessions
* Create sessions
* Chat with existing sessions
* Stream responses in real time
* Execute tools
* Receive permission requests
* Approve or reject tool calls

The architecture should resemble AnyDesk/Tailscale, but for AI agents.

---

# High Level Architecture

```
                Flutter App
                     │
               WebSocket / HTTPS
                     │
             VPS Relay Server
                     │
      ┌──────────────┴──────────────┐
      │                             │
 PC Daemon A                  PC Daemon B
      │                             │
 ┌────┴─────┐                ┌──────┴──────┐
 │          │                │             │
Claude   OpenCode         Codex      Gemini CLI
```

---

# Components

## 1. Relay

Runs on VPS.

Responsibilities

* Authentication
* Device registry
* Routing
* Session routing
* Message broadcast
* Heartbeats
* Offline detection

Never communicates directly with AI.

Only forwards ACP messages.

---

## 2. Daemon

Runs on user's PC.

Responsibilities

* Detect local ACP agents
* Launch agents
* Stop agents
* Restart crashed agents
* Maintain WebSocket to relay
* Forward ACP traffic
* Stream outputs
* Logging

---

## 3. Agent Manager

Responsible for

* Discovering installed agents
* Registering capabilities
* Launching processes
* Monitoring health
* Auto restart

Supported agents

* Claude Code
* Codex
* OpenCode
* Gemini CLI
* Custom ACP

---

## 4. Flutter App

Features

Device List

Agent List

Session List

Chat

Create Session

Delete Session

Rename Session

Reconnect

Permission Dialog

Streaming Responses

Dark Mode

---

# Repository Structure

```
acp-remote/

    apps/

        relay/

        daemon/

        flutter/

        cli/

    packages/

        acp/

        protocol/

        common/

        logging/

        auth/

        websocket/

        session/

        models/

        storage/

    tests/

        integration/

        relay/

        daemon/

        protocol/

    docs/

    scripts/

    docker/

```

---

# Daemon Structure

```
daemon/

    main.py

    config.py

    connection.py

    relay_client.py

    session_manager.py

    process_manager.py

    discovery.py

    health.py

    logger.py

    auth.py

    config/

    logs/

```

---

# Relay Structure

```
relay/

    main.py

    websocket.py

    auth.py

    device_manager.py

    session_manager.py

    router.py

    heartbeat.py

    permissions.py

    logger.py

    storage.py

    config.py

```

---

# Flutter Structure

```
flutter/

    screens/

        devices/

        agents/

        sessions/

        chat/

        settings/

    providers/

    websocket/

    models/

    widgets/

    services/

```

---

# Session Flow

Phone

↓

Relay

↓

Daemon

↓

Agent

↓

Daemon

↓

Relay

↓

Phone

---

# Logging

Every component must write logs.

```
logs/

relay.log

daemon.log

flutter.log

agent.log

errors.log

```

Each log entry contains

* Timestamp
* Component
* Level
* Session ID
* Device ID
* Message

Example

```
2026-06-22 10:15:20

Relay

INFO

Device connected

device=abc123
```

---

# Error Handling

Every exception must

* be logged
* include traceback
* include request payload
* include session id

No exception should silently fail.

---

# Verification Pipeline

Every code change must follow:

1. Run formatter
2. Run linter
3. Run unit tests
4. Run integration tests
5. Verify relay connection
6. Verify daemon connection
7. Verify session creation
8. Verify streaming
9. Verify reconnect
10. Verify logs

No feature is complete until all verification passes.

---

# Development Phases

## Phase 1

Relay

Daemon

Basic chat

## Phase 2

Multi-device

Authentication

Reconnect

Heartbeat

## Phase 3

Multiple agents

Agent discovery

Session management

## Phase 4

Permissions

Tool execution

Streaming

## Phase 5

Authentication

Encryption

Compression

## Phase 6

Production deployment

Docker

CI/CD

Monitoring

Metrics

Backups

---

# Future Features

Voice chat

Image support

File transfer

Remote terminal

Remote filesystem

Remote editing

Screen sharing

Collaborative sessions

Plugin marketplace

MCP registry

Cloud synchronization
