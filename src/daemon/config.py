import json
import os
import shutil
import socket


RELAY_HOST = os.environ.get("ACP_RELAY_HOST", "localhost")
RELAY_PORT = os.environ.get("ACP_RELAY_PORT", "8000")
RELAY_URL = os.environ.get(
    "ACP_RELAY_URL",
    f"ws://{RELAY_HOST}:{RELAY_PORT}/daemon",
)

_raw_agent_command = os.environ.get("ACP_AGENT_COMMAND", '["opencode", "acp"]')
AGENT_COMMAND = json.loads(_raw_agent_command)


def _detect_acp_agents() -> list[dict]:
    agents = []
    # opencode — native ACP mode
    if shutil.which("opencode"):
        agents.append({"id": "opencode", "name": "OpenCode", "command": ["opencode", "acp"]})
    # codex — ACP adapter, check for the actual binary
    if shutil.which("codex-acp"):
        agents.append({"id": "codex", "name": "Codex", "command": ["codex-acp"]})
    elif shutil.which("npx"):
        agents.append({"id": "codex", "name": "Codex", "command": ["npx", "-y", "@agentclientprotocol/codex-acp"]})
    # claude — ACP adapter, check for the actual binary
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
