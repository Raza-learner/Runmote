import json
import os
import shutil
import socket
import sys


RELAY_HOST = os.environ.get("ACP_RELAY_HOST", "relay.runmote.dev")
RELAY_PORT = os.environ.get("ACP_RELAY_PORT", "443")
_raw_relay_url = os.environ.get("ACP_RELAY_URL", "") or f"wss://{RELAY_HOST}/daemon"
# Auto-convert http/https to ws/wss so users can pass an https URL
if _raw_relay_url.startswith("https://"):
    RELAY_URL = _raw_relay_url.replace("https://", "wss://", 1)
elif _raw_relay_url.startswith("http://"):
    RELAY_URL = _raw_relay_url.replace("http://", "ws://", 1)
else:
    RELAY_URL = _raw_relay_url
_raw_agent_command = os.environ.get("ACP_AGENT_COMMAND", '["opencode", "acp"]')
AGENT_COMMAND = json.loads(_raw_agent_command)


def _detect_acp_agents() -> list[dict]:
    agents = []
    # opencode — native ACP mode (check PATH + common Windows locations)
    _has_opencode = bool(shutil.which("opencode"))
    if not _has_opencode and sys.platform == "win32":
        for base in [os.environ.get("LOCALAPPDATA", ""), os.environ.get("PROGRAMFILES", ""), os.environ.get("USERPROFILE", "")]:
            if not base:
                continue
            for rel in [r"Programs\opencode\opencode.exe", r"OpenCode\opencode.exe", r".opencode\bin\opencode.exe", r"AppData\Local\opencode\opencode.exe"]:
                if os.path.isfile(os.path.join(base, rel)):
                    _has_opencode = True
                    break
            if _has_opencode:
                break
    if _has_opencode:
        agents.append({"id": "opencode", "name": "OpenCode", "command": ["opencode", "acp"]})
    # codex — only if the codex CLI is installed (adapter bridges it to ACP)
    if shutil.which("codex"):
        if shutil.which("codex-acp"):
            agents.append({"id": "codex", "name": "Codex", "command": ["codex-acp"]})
        elif shutil.which("npx"):
            agents.append({"id": "codex", "name": "Codex", "command": ["npx", "-y", "@agentclientprotocol/codex-acp"]})
    # claude — only if the claude CLI is installed (adapter bridges it to ACP)
    _has_claude = shutil.which("claude") or shutil.which("claude-code")
    if _has_claude:
        if shutil.which("claude-agent-acp"):
            agents.append({"id": "claude", "name": "Claude Code", "command": ["claude-agent-acp"]})
        elif shutil.which("npx"):
            agents.append({"id": "claude", "name": "Claude Code", "command": ["npx", "-y", "@agentclientprotocol/claude-agent-acp"]})
    # gemini — native ACP mode
    if shutil.which("gemini"):
        agents.append({"id": "gemini", "name": "Gemini", "command": ["gemini", "--acp"]})
    # cursor — native ACP mode
    if shutil.which("cursor-agent"):
        agents.append({"id": "cursor", "name": "Cursor", "command": ["cursor-agent", "acp"]})
    # copilot — native ACP mode
    if shutil.which("copilot"):
        agents.append({"id": "copilot", "name": "Copilot", "command": ["copilot", "--acp", "--stdio"]})
    # openclaw — native ACP mode
    if shutil.which("openclaw"):
        agents.append({"id": "openclaw", "name": "OpenClaw", "command": ["openclaw", "acp"]})
    return agents if agents else [{"id": "default", "name": "Agent", "command": AGENT_COMMAND}]


_raw_agent_commands = os.environ.get("ACP_AGENT_COMMANDS")
if _raw_agent_commands:
    AGENT_CONFIGS = json.loads(_raw_agent_commands)
else:
    AGENT_CONFIGS = _detect_acp_agents()

DAEMON_ID = os.environ.get("ACP_DAEMON_ID", socket.gethostname())
DAEMON_TOKEN = os.environ.get("ACP_DAEMON_TOKEN", "")
RECONNECT_DELAY = int(os.environ.get("ACP_RECONNECT_DELAY", "5"))

# Log detected agents for debugging
_detected_ids = [a["id"] for a in AGENT_CONFIGS]
if _detected_ids:
    print(f"agents detected: {', '.join(_detected_ids)}", flush=True)
else:
    print("no ACP agents detected — install opencode, codex, or claude", flush=True)
