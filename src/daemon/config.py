import json
import os
import shutil
import socket
import sys
from pathlib import Path


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


def _find_exe(name, *win_dirs):
    """Find executable on PATH, returning full path or None.
    On Windows also check known install dirs with .cmd/.bat/.exe extensions."""
    path_hit = shutil.which(name)
    if path_hit:
        print(f"[ACP-DETECT] {name}: found on PATH at {path_hit}", flush=True)
        return path_hit
    if sys.platform != "win32":
        return None
    extensions = (".cmd", ".bat", ".exe", "")
    for directory in win_dirs:
        if not directory:
            continue
        if os.path.isdir(directory):
            for entry in os.scandir(directory):
                if entry.is_file():
                    lower_name = entry.name.lower()
                    for ext in extensions:
                        if lower_name == (name + ext).lower():
                            full = os.path.join(directory, entry.name)
                            print(
                                f"[ACP-DETECT] {name}: found in {directory} ({entry.name})",
                                flush=True,
                            )
                            return full
    return None


def _detect_acp_agents() -> list[dict]:
    agents = []

    # Known Windows install directories per agent
    _local = os.environ.get("LOCALAPPDATA", "")
    _appdata = os.environ.get("APPDATA", "")
    _pf = os.environ.get("PROGRAMFILES", "")
    _pf86 = os.environ.get("PROGRAMFILES(X86)", "")
    _home = os.environ.get("USERPROFILE", "")
    _programdata = os.environ.get("PROGRAMDATA", "")
    _npm = os.path.join(_appdata, "npm") if _appdata else ""
    _localbin = os.path.join(_home, ".local", "bin") if _home else ""
    _cargo = os.path.join(_home, ".cargo", "bin") if _home else ""
    _bun = os.path.join(_home, ".bun", "bin") if _home else ""
    _scoop = os.path.join(_home, "scoop", "shims") if _home else ""
    _choco = os.path.join(_programdata, "chocolatey", "bin") if _programdata else ""
    _winget = os.path.join(_local, "Microsoft", "WinGet", "Links") if _local else ""
    _pythonscripts = os.path.join(_appdata, "Python", "Scripts") if _appdata else ""
    _dotnet = os.path.join(_home, ".dotnet", "tools") if _home else ""

    # opencode — native ACP mode
    opencode_cmd = _find_exe(
        "opencode", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet
    )
    if opencode_cmd:
        agents.append({"id": "opencode", "name": "Opencode", "command": [opencode_cmd, "acp"]})

    # cursor — native ACP mode (binary: cursor-agent or agent)
    cursor_paths = []
    if _local:
        for sub in ("cursor", "Cursor"):
            cursor_paths.append(os.path.join(_local, "Programs", sub))
            cursor_paths.append(os.path.join(_local, "Programs", sub, "resources", "app"))
    if _pf:
        cursor_paths.extend([os.path.join(_pf, "Cursor"), os.path.join(_pf, "cursor")])
    if _pf86:
        cursor_paths.extend([os.path.join(_pf86, "Cursor"), os.path.join(_pf86, "cursor")])
    cursor_paths.extend([_localbin, _npm, _scoop, _choco, _winget, _pythonscripts, _dotnet])

    found = _find_exe("cursor-agent", *cursor_paths)
    if not found:
        found = _find_exe("agent", *cursor_paths)
    if found:
        agents.append({"id": "cursor", "name": "Cursor", "command": [found, "acp"]})

    # codex — CLI + ACP adapter
    codex_cli = _find_exe("codex", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    if codex_cli:
        codex_acp = _find_exe("codex-acp", _npm, _localbin, _scoop, _choco, _winget, _pythonscripts, _dotnet)
        if codex_acp:
            agents.append({"id": "codex", "name": "Codex", "command": [codex_acp]})
        elif shutil.which("npx"):
            agents.append({"id": "codex", "name": "Codex", "command": ["npx", "-y", "@agentclientprotocol/codex-acp"]})

    # claude — CLI + ACP adapter
    claude_cli = (
        _find_exe("claude", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
        or _find_exe("claude-code", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    )
    if claude_cli:
        claude_acp = _find_exe(
            "claude-agent-acp", _npm, _localbin, _scoop, _choco, _winget, _pythonscripts, _dotnet
        )
        if claude_acp:
            agents.append({"id": "claude", "name": "Claude Code", "command": [claude_acp]})
        elif shutil.which("npx"):
            agents.append(
                {
                    "id": "claude",
                    "name": "Claude Code",
                    "command": ["npx", "-y", "@agentclientprotocol/claude-agent-acp"],
                }
            )

    # github-copilot — CLI + ACP adapter
    copilot_cli = (
        _find_exe("gh", _localbin, _npm, _cargo, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    )
    if copilot_cli:
        copilot_acp = _find_exe(
            "github-copilot-acp", _npm, _localbin, _scoop, _choco, _winget, _pythonscripts, _dotnet
        )
        if copilot_acp:
            agents.append({"id": "copilot", "name": "GitHub Copilot", "command": [copilot_acp]})
        elif shutil.which("npx"):
            agents.append(
                {
                    "id": "copilot",
                    "name": "GitHub Copilot",
                    "command": ["npx", "-y", "@agentclientprotocol/github-copilot-acp"],
                }
            )

    if agents:
        return agents
    # Fallback: use AGENT_COMMAND (defaults to ["opencode", "acp"])
    exe = shutil.which(AGENT_COMMAND[0]) if AGENT_COMMAND else None
    if exe:
        return [{"id": "default", "name": "Agent", "command": AGENT_COMMAND}]
    return []


_raw_agent_commands = os.environ.get("ACP_AGENT_COMMANDS")
if _raw_agent_commands:
    AGENT_CONFIGS = json.loads(_raw_agent_commands)
else:
    AGENT_CONFIGS = _detect_acp_agents()

DAEMON_ID = os.environ.get("ACP_DAEMON_ID", socket.gethostname())
DAEMON_TOKEN = os.environ.get("ACP_DAEMON_TOKEN", "")
if not DAEMON_TOKEN:
    try:
        token_file = Path.home() / ".config" / "runmote" / "daemon-token"
        if token_file.exists():
            DAEMON_TOKEN = token_file.read_text().strip()
    except Exception:
        pass
RECONNECT_DELAY = int(os.environ.get("ACP_RECONNECT_DELAY", "5"))

# Log detected agents for debugging
_detected_ids = [a["id"] for a in AGENT_CONFIGS]
if _detected_ids:
    print(f"agents detected: {', '.join(_detected_ids)}", flush=True)
else:
    print("no ACP agents detected — install opencode, codex, or claude", flush=True)
